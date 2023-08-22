import CoreData
import UIKit

final class DBController: CRUD {
    private var appDelegate: AppDelegate?
    private var context: NSManagedObjectContext?
    
    init() {
        guard let currentAppDelegate = UIApplication.shared.delegate as? AppDelegate else {
            debugPrint("Get AppDelegate error")
            return
        }
        
        self.appDelegate = currentAppDelegate
        self.context = appDelegate?.persistentContainer.viewContext
        
        debugPrint("-->> Path: \(String.localPath() ?? "Get local path error")")
    }
    
    func create<T>(entityName: EntityName) -> T? {
        guard let context = self.context else {
            debugPrint("Get context error")
            return nil
        }
        
        guard let entity = NSEntityDescription.entity(forEntityName: entityName.rawValue, in: context) else {
            debugPrint("Get entity error")
            return nil
        }
        return NSManagedObject(entity: entity, insertInto: context) as? T
    }
    
    func insert<T>(string: String, managedObject: T) {
        guard let managedObject = managedObject as? NSManagedObject else {
            debugPrint("Get managedObject error")
            return
        }
        
        managedObject.setValue(Int64.generateId(), forKey: "id")
        managedObject.setValue(string, forKey: "url")
        managedObject.setValue(Date.now, forKey: "date")
        
        do {
            try self.context?.save()
        } catch {
            debugPrint("Set Content error")
        }
    }
    
    func retrieve<T>(entityName: EntityName, predicate: NSPredicate?) -> [T]? where T : NSObject{
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName.rawValue)
        
        fetchRequest.predicate = predicate
        
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let result = try self.context?.fetch(fetchRequest)
            return result as? [T]
        } catch {
            debugPrint("Get Fetch Request error")
            return nil
        }
    }
    
    func update() -> Bool {
        return false
    }
    
    func delete(name: String) -> Bool {
        let predicate = NSPredicate(format: "name = %@", name)
                
        do {
            guard let results = retrieve(entityName: .Content, predicate: predicate) as? [NSManagedObject] else {
                debugPrint("Get result for delete register error")
                return false
            }
            
            for register in results {
                context?.delete(register)
            }
            
            try context?.save()
            return true
            
        } catch {
            debugPrint("Delete register error")
            return false
        }
    }
}
