class Subscription < ActiveRecord::Base
  include AASM
  extend Enumerize

  belongs_to :user
  belongs_to :plan
  has_many :transactions

  enumerize :plan_duration, in: [:month, :year], default: :month, predicates: true, scope: true

  scope :billable, -> { self.or({aasm_state: 'active'}, {aasm_state: 'past_due'}) }
  scope :billable_on, -> (date) { where(next_payment_due: date) }
  scope :trial_due_on, -> (date) { where(trial_due: date) }

  validates :plan_duration, presence: true

  before_validation :set_trial, on: :create

  aasm do
    state :to_pending
    state :activate

    event :to_pending do
      transitions :from => :activate, :to => :to_pending
    end

    event :activate do
      transitions :from => :to_pending, :to => :activate
    end

  end
  
  def amount
    if plan_duration.year?
      plan.year_price
    else
      plan.month_price
    end
  end

  def account
    user.account
  end

  def renew!
    update_subscription!
  end

  def update_subscription!(response)
    if response.success?
      activate_subscription!
    else
      logger.error "****Subscription Error****"
      logger.error response.message

      self.last_charge_error = response.message
      self.failed_transactions_number += 1

      if self.failed_transactions_number < configatron.retry_number
        self.past_due! || self.save!
      else
        self.to_pending! do
          UserMailer.delay.subscription_cancelled(self.user.id)
        end
      end
    end
    record_transaction!(response.params)
  end

  def activate_subscription!(plan=nil, params=nil)
    record_transaction!(params) if params.present?
    self.plan = Plan.find(plan) if plan.present?
    self.last_charge_error = nil
    self.failed_transactions_number = 0
    self.successful_transactions_number += 1
    if self.plan.month_price == 0 
      self.next_payment_due = nil
    else
      self.next_payment_due = next_billing_date(next_payment_due)
    end
    self.activate!
  end

  def next_billing_date(date=Date.today)
    date ||= Date.today
    period = plan_duration.month? ? 1.month : 1.year
    date + period
  end

  def self.renew!
    billable.billable_on(Date.today).each do |subscription|
      subscription.renew!
    end
  end
  
  def self.pending!
    trial.trial_due_on(Date.today).each do |subscription|
      subscription.to_pending! do
        UserMailer.delay.trial_over(subscription.user.id)
      end
    end
  end

  private

  def set_trial
    self.trial_due = Date.today + 7
  end

  def record_transaction!(params)
    transactions.create! cp_transaction_attrs(params)
  end

  def cp_transaction_attrs(attrs)
    attrs = ActionController::Parameters.new attrs
    p = attrs.permit(:TransactionId, :Amount, :Currency, :DateTime, :IpAddress, :IpCountry, :IpCity, :IpRegion, :IpDistrict, :Description, :Status, :Reason, :AuthCode).transform_keys!{ |key| key.to_s.underscore rescue key }
    p[:status] = p[:status].underscore if p[:status].present?
    p[:reason] = p[:reason].titleize if p[:reason].present?
    p[:date_time] = DateTime.parse(attrs[:CreatedDateIso]) if attrs[:CreatedDateIso].present?
    p
  end
end