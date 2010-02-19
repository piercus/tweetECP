# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_tweet_session',
  :secret      => '4d52a8ec2b7e15cbf3cbab6e8767f9a8c7abddd4fc4c6113ee45c98f6dea241e03ef7074fcd142de359e874bee0915d2c2547b4d06c276c4f866e3f2440cda5d'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
