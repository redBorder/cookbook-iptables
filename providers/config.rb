action :add do
  begin
     # ... your code here ...
     Chef::Log.info("cookbook-example has been configured correctly.")
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :remove do
  begin
     # ... your code here ...
     Chef::Log.info("cookbook-example has been deleted correctly.")
  rescue => e
    Chef::Log.error(e.message)
  end
end
