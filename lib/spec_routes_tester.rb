class SpecRoutesTester
  def self.draw(&block)
    yield self.new(eval('self', block.binding))
  end

  def initialize(example)
    @example = example
  end

  def resources(*entities)
    entities.each do |entity|
      plural = entity.to_s
      singular = plural.singularize
      with_options :controller => plural do |m|
        m.send       "#{plural}", "#{plural}",          :action => "index",   :conditions => {:method => :get}
        m.send       "#{plural}", "#{plural}",          :action => "create",  :conditions => {:method => :post}
        m.send "new_#{singular}", "#{plural}/new",      :action => "new",     :conditions => {:method => :get}
        m.with_options :id => '1' do |mi|
          mi.send "edit_#{singular}", "#{plural}/1/edit", :action => "edit",    :conditions => {:method => :get}
          mi.send      "#{singular}", "#{plural}/1",      :action => "show",    :conditions => {:method => :get}
          mi.send      "#{singular}", "#{plural}/1",      :action => "update",  :conditions => {:method => :put}
          mi.send      "#{singular}", "#{plural}/1",      :action => "destroy", :conditions => {:method => :delete}
        end
      end
    end
  end

  def method_missing(method, *args, &block)
    if args.length == 2 && args[0].is_a?(String) && args[1].is_a?(Hash)
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
    else
      super(method, *args, &block)
    end
  end
end
