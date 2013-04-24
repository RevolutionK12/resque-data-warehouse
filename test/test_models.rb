module Facts
  # Warehoused models end up in the Facts namespace, e.g. Facts::AssignmentStateFact
end

class Transactional < ActiveRecord::Base
  warehoused
end

class Facts::TransactionalFact < ActiveRecord::Base
  def execute_transaction
    # puts "executing transaction on transactional fact"
    self.save!
  end
end
