class SubscriptionsController < ApplicationController
  require "paypal/recurring"

  before_filter :authenticate_user!
  before_action :set_subscription, only: [:show]
  
  respond_to :html
  
  def new
		@plans = Plan.order('month_price ASC').all
    redirect_to '/cars/' if !current_user.subscription.nil?
  end
  
  def show
    respond_with(@subscription)
  end
  
  def create
		@subscription = Subscription.new(subscription_params)
		@subscription.user_id = current_user.id
		if @subscription.save!
	    plan = Plan.find(@subscription.plan_id)
	    if plan.month_price.to_i == 0
	    	@subscription.activate_subscription!
	    	redirect_to cars_path
	    else
				ppr = init_reccuring(plan)
				response = ppr.checkout
				redirect_to response.checkout_url if response.valid?
			end
		end
  end

  def callback
    @subscription = Subscription.find(params[:subscription_id])
		plan = Plan.find(@subscription.plan_id)
		ppr = reccuring_callback(plan)
		response = ppr.request_payment
		if response.approved? and response.completed?
			profile_id = create_reccuring(plan)
			if !profile_id.nil?
				set_subscription_profile_id(profile_id)
				@subscription.activate_subscription!
				redirect_to "/cars/"
			else 
			  redirect_to "/cars/"
			end
		else
	  	render :text=> response.errors
		end
  end
  
  def canceled
		redirect_to 'subscriptions/new'
  end
  
  private 
  
  
	def set_subscription
    @subscription = Subscription.find(params[:id])
  end

  def init_reccuring(plan)
  	PayPal::Recurring.new({
				  :return_url   => "http://198.38.86.211:3000/subscriptions/callback?subscription_id=#{@subscription.id}",
				  :cancel_url   => "http://198.38.86.211:3000/subscriptions/canceled",
				  :ipn_url      => "http://198.38.86.211:3000/subscriptions/ipn",
				  :description  => plan.name,
				  :amount       => plan.month_price,
				  :currency     => "USD"
		})
  end
	
	def create_reccuring(plan)
	  ppr = PayPal::Recurring.new({
			:amount      => @subscription.amount,
			:currency    => "USD",
			:description => plan.name,
			:ipn_url     => "http://198.38.86.211:3000/subscriptions/ipn",
			:frequency   => 1,
			:token       => params[:token],
			:period      => :monthly,
			:reference   => "1234",
			:payer_id    => params[:Payer_id],
			:start_at    => Time.now,
			:failed      => 1,
			:outstanding => :next_billing
		})

		response = ppr.create_recurring_profile
		response.profile_id
	end
	
	def reccuring_callback(plan)
		PayPal::Recurring.new({
	  :token       => params[:token],
	  :payer_id    => params[:PayerID],
	  :amount      => @subscription.amount,
	  :description => plan.name
		})
	end

	def set_subscription_profile_id(profile_id)
		@subscription.profile_id = profile_id
		@subscription.save!
	end
  
  def subscription_params
    params.permit(:plan_id, :plan_duration)
  end
end
