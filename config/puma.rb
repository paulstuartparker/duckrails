workers ENV.fetch("PUMA_WORKERS") { 3 }
port ENV.fetch("PUMA_LISTEN_PORT") { 5050 }

preload_app!

on_worker_boot do
  ActiveSupport.on_load(:active_record) do
    ActiveRecord::Base.establish_connection
  end
end
