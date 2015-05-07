ThinkingSphinx::Index.define :car, :with => :real_time do
    indexes client_no, stock_no , dealer_code, make, model, series, badge, body, doors, seats, body_colour, trim_colour, gears , gearbox, fuel_type, retail, rego, odometer, cylinders, engine_capacity, vin_number, engine_number, manu_month, options, comments, nvic, redbookcode, location, status
    has manu_year, :type => :integer
end