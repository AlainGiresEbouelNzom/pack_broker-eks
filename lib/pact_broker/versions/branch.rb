require "pact_broker/dataset"

module PactBroker
  module Versions
    class Branch < Sequel::Model(:branches)
      set_primary_key :id
      plugin :timestamps, update_on_create: true
      plugin :insert_ignore, identifying_columns: [:name, :pacticipant_id]

      associate(:many_to_one, :pacticipant, :class => "PactBroker::Domain::Pacticipant", :key => :pacticipant_id, :primary_key => :id)
      associate(:one_to_many, :branch_versions, :class => "PactBroker::Versions::BranchVersion", :key => :branch_id, :primary_key => :id)

      dataset_module(PactBroker::Dataset)
    end
  end
end

# Table: branches
# Columns:
#  id             | integer                     | PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY
#  name           | text                        |
#  pacticipant_id | integer                     | NOT NULL
#  created_at     | timestamp without time zone | NOT NULL
#  updated_at     | timestamp without time zone | NOT NULL
# Indexes:
#  branches_pkey                      | PRIMARY KEY btree (id)
#  branches_pacticipant_id_name_index | UNIQUE btree (pacticipant_id, name)
# Foreign key constraints:
#  branches_pacticipant_id_fkey | (pacticipant_id) REFERENCES pacticipants(id) ON DELETE CASCADE
# Referenced By:
#  branch_heads    | branch_heads_branch_id_fkey | (branch_id) REFERENCES branches(id) ON DELETE CASCADE
#  branch_versions | branch_versions_branches_fk | (branch_id) REFERENCES branches(id) ON DELETE CASCADE
