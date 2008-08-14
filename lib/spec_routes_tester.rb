class SpecRoutesTester
  def initialize(example)
    @example = example
  end

  def method_missing(method, *args, &block)
    args.length.should == 2

    route = args[0][0, 1] == '/' ? args[0] : "/#{args[0]}"
    params = args[1]
    http_method = (params.delete(:conditions) || {})[:method]
    essential_params = params.reject{ |k, v| [:action, :controller].include?(k) }

    @example.route_for(params).should == route
    @example.params_from(http_method, route).should == params

    begin
      @example.process params[:action], essential_params
    rescue ActiveRecord::RecordNotFound
    end

    @example.send("#{method}_path", essential_params).should == route
  end
end
