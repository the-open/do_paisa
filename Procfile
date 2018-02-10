web: bundle exec puma -t 5:5 -p ${PORT:-3000} -e ${RACK_ENV:-development}
sidekiq: RAILS_MAX_THREADS=${SIDEKIQ_WORKERS:-10} bundle exec sidekiq