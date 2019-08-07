class ActiveStorage::AnalyzeJob < ActiveStorage::BaseJob
  self.queue_adapter = :inline

  def perform(blob)
    blob.analyze
  end
end