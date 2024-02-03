require "pact_broker/dataset"

module PactBroker
  module Deployments
    class ReleasedVersion < Sequel::Model
      set_primary_key :id

      many_to_one :pacticipant, :class => "PactBroker::Domain::Pacticipant", :key => :pacticipant_id, :primary_key => :id
      many_to_one :version, :class => "PactBroker::Domain::Version", :key => :version_id, :primary_key => :id
      many_to_one :environment, :class => "PactBroker::Deployments::Environment", :key => :environment_id, :primary_key => :id

      plugin :timestamps, update_on_create: true
      plugin :insert_ignore, identifying_columns: [:version_id, :environment_id]

      dataset_module do
        include PactBroker::Dataset

        def currently_supported
          where(support_ended_at: nil)
        end

        def for_environment_name(environment_name)
          where(environment_id: db[:environments].select(:id).where(name: environment_name))
        end

        def for_pacticipant_name(pacticipant_name)
          where(pacticipant_id: db[:pacticipants].select(:id).where(Sequel.name_like(:name, pacticipant_name)))
        end

        def for_pacticipant_version_number(pacticipant_version_number)
          where(version_id: db[:versions].select(:id).where(Sequel.name_like(:number, pacticipant_version_number)))
        end

        def for_version_and_environment(version, environment)
          where(version_id: version.id, environment_id: environment.id)
        end

        def for_environment(environment)
          where(environment_id: environment.id)
        end

        def order_by_date_desc
          order(Sequel.desc(:created_at), Sequel.desc(:id))
        end

        def record_support_ended
          where(support_ended_at: nil).update(support_ended_at: Sequel.datetime_class.now)
        end

        def set_currently_supported
          exclude(support_ended_at: nil).update(support_ended_at: nil, updated_at: Sequel.datetime_class.now)
        end
      end

      def record_support_ended
        self.class.where(id: id).record_support_ended
        refresh
      end

      def currently_supported
        support_ended_at == nil
      end

      def version_number
        version.number
      end

      def environment_name
        environment.name
      end
    end
  end
end

# Table: released_versions
# Columns:
#  id               | integer                     | PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY
#  uuid             | text                        | NOT NULL
#  version_id       | integer                     | NOT NULL
#  pacticipant_id   | integer                     | NOT NULL
#  environment_id   | integer                     | NOT NULL
#  created_at       | timestamp without time zone |
#  updated_at       | timestamp without time zone |
#  support_ended_at | timestamp without time zone |
# Indexes:
#  released_versions_pkey                            | PRIMARY KEY btree (id)
#  released_versions_uuid_index                      | UNIQUE btree (uuid)
#  released_versions_version_id_environment_id_index | UNIQUE btree (version_id, environment_id)
#  released_version_support_ended_at_index           | btree (support_ended_at)
# Foreign key constraints:
#  released_versions_environment_id_fkey | (environment_id) REFERENCES environments(id)
#  released_versions_version_id_fkey     | (version_id) REFERENCES versions(id)
