import UIKit

class ThumbNailViewModel {
    var numberOfSections: Int {
        return 1
    }

    var numberItemsSections: Int {
        guard let list = fetchJsonModel(filename: "Videos") else { return 0 }
        return list.count
    }

    var data: [ThumbNailModel]? {
        guard let list = fetchJsonModel(filename: "Videos") else { return nil }
        return list
    }
    
    lazy var index:(ThumbNailModel?)->IndexPath? = { index in
        guard let data = self.data, let index = index else { return IndexPath(item: 0, section: 0)}
        let selectiveIndex = self.data?.firstIndex(where: { $0.id == index.id })
        return IndexPath(item: selectiveIndex!, section: 0)
    }

}

extension ThumbNailViewModel {
    private func fetchJsonModel(filename fileName: String) -> [ThumbNailModel]? {
        if let url = Bundle.main.url(forResource: fileName, withExtension: ".json") {
            do {
                let data = try Data(contentsOf: url)
                guard let videosList = data.dataAtKeyPath("Resource") else { return nil }
                let jsonData = try JSONDecoder().decode([ThumbNailModel].self, from: videosList)
                return jsonData
            } catch {
                print("error:\(error)")
            }
        }
        return nil
    }
}

extension Data {
    func dataAtKeyPath(_ keyPath: String) -> Data? {
        let rootJson = try? JSONSerialization.jsonObject(with: self, options: JSONSerialization.ReadingOptions.mutableContainers)
        guard let keyedJson = (rootJson as AnyObject).value(forKeyPath: keyPath) else { return nil }
        guard !(keyedJson is NSNull) else { return nil }
        return try? JSONSerialization.data(withJSONObject: keyedJson)
    }
}
