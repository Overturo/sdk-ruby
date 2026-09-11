# frozen_string_literal: true

module Overturo
  module Resources
    module Core
      # Per spec 78 §3.A.1, the accounts route is `resources :accounts, only: [:index]`.
      # Create / Retrieve / Update / Delete were declared on the route table but
      # never had controller actions — every call returned 404 (or worse,
      # ActionNotFound deep in the stack pre-spec-78).
      #
      # Account creation happens through the dashboard signup flow, not the API.
      # Per-account configuration lives on `current_account` server-side.
      class Accounts < ApiResource
        include ApiOperations::List

        RESOURCE_PATH = "/accounts"
        OBJECT_KEY = "account"
        LIST_KEY = "accounts"
      end
    end
  end
end
