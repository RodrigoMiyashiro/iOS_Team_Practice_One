import Foundation

protocol CRUD {
    func create<T>(entityName: EntityName) -> T? where T : NSObject
    func insert<T>(string: String, managedObject: T)
    func retrieve<T>(entityName: EntityName, predicate: NSPredicate?) -> [T]? where T : NSObject
    func update() -> Bool
    func delete(name: String) -> Bool
}
