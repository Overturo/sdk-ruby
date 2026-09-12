# frozen_string_literal: true

module Overturo
  module Resources
    module Delegate
      # `/api/v1/delegations` supports index/create/show/update. There is **no**
      # bare DELETE endpoint — delegations are torn down via the `/revoke`
      # member action, which is mounted as `DELETE /delegations/:id/revoke`
      # (the verb encodes destruction; the path encodes that revocation is a
      # specific lifecycle event distinct from a hard delete).
      class Delegations < ApiResource
        include ApiOperations::Create
        include ApiOperations::Retrieve
        include ApiOperations::List
        include ApiOperations::Update

        RESOURCE_PATH = "/delegations"
        # 193 D12 — endpoints built by explicit http_client calls below.
        declare_endpoint :delete, "<resource>/{id}/revoke"
        OBJECT_KEY = "delegation_grant"
        LIST_KEY = "delegation_grants"

        # Revoke uses DELETE on a member sub-path. `custom_action` only knows
        # :get and :post, so this is written explicitly. `http_client.delete`
        # doesn't accept a body or params — the action takes the id and that's
        # the entire contract.
        def revoke(id)
          response = http_client.delete("#{RESOURCE_PATH}/#{id}/revoke")
          unwrap(response)
        end
      end
    end
  end
end
