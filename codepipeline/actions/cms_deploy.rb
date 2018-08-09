{
  category: 'Deploy',
  provider: 'CmsImportTask',
  version:  "5b6b53fc", # Time.now.to_i.to_s(16),
  configuration_properties: [
    {
      name: "cluster", # required
      required: true, # required
      key: false, # required
      secret: false, # required
      queryable: true,
      description: "Target Cluster",
      type: "String",
    },
  ],
  input_artifact_details: {
    minimum_count: 1, 
    maximum_count: 1, 
  },
  output_artifact_details: {
    minimum_count: 0,
    maximum_count: 0,
  },
}
