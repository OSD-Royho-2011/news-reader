
Sidekiq::Extensions.enable_delay!

Sidekiq.configure_server do |config|
  config.redis = { url: ENV["REDIS_URL"] }
  config.periodic do |mgr|
    mgr.register('*/10 * * * *', "RefreshWebDataWorker")
  end
  config.super_fetch!
  config.reliable_scheduler!
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV["REDIS_URL"] }
end
