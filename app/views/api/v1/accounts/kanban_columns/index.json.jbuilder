json.array! @kanban_columns do |kanban_column|
  json.partial! 'api/v1/models/kanban_column', formats: [:json], resource: kanban_column
end
