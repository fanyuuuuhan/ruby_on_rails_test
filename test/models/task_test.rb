require "test_helper"

# == Schema Information
#
# Table name: tasks
#
#  id         :bigint           not null, primary key
#  content    :text
#  status     :string           default("pending"), not null
#  title      :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class TaskTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
