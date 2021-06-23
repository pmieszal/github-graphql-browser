import Apollo

extension GraphQLQuery {
    var watcherKey: String {
        let variables = self.variables?.sorted { $0.key > $1.key } ?? []
        
        var watcherKey = operationName
        
        for field in variables {
            watcherKey.append(field.key)
            watcherKey.append(":")
            
            if let value = field.value?.jsonValue,
               let valueString = try? String(jsonValue: value) {
                watcherKey.append(valueString)
            }
        }
        
        return watcherKey
    }
}
