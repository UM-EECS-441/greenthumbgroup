//
//  gardenGuides.swift
//  Green Thumb
//
//  Created by Tiger Shi on 10/20/20.
//

import UIKit

class guideTable: UIViewController {
    private let refreshControl = UIRefreshControl()
    
    
//    var guides = [["_id":["$oid":"5f8c6e6fc7a33e9aa8d50feb"],"references":"","text":"guide to monkies.","title":"monke"]]
    var guides = [["_id":["$oid":""], "references":"", "text":"", "title":""]]
//    var guides = [["_id":["$oid":"5f8c6e6fc7a33e9aa8d50feb"],"references":"","text":"Animals such as deer and groundhogs can do considerable damage to your garden if allowed access to it, but luckily this can largely be prevented. Proper fencing of your garden to keep deer out, though, usually requires 8 foot tall fencing, which is certainly not a trivial task. An alternative to fencing to stop deers specifically is using deer repellants, which require regular application to work, but are largely successful in repelling deer. To keep groundhogs and other rodents out of your gardens a chicken wire fence that starts about 8 inches to a foot underground is best so as to keep them from digging under it.","title":"animals"],["_id":["$oid":"5f8c6e76c7a33e9aa8d50fec"],"references":"https://www.ortho.com/en-us/library/garden/vegetable-garden-pests","text":"Bugs can cause wreak havoc in a garden. They can damage and even kill plants, and if you don`t know the right techniques then they`re impossible to deal with. The first such technique is to plant marigolds, whose smell repels mosquitoes and nematodes while at the same time actually attracting good bugs that eat aphids. In fact there are many such plants which attract good bugs that eat other bugs, for example dill attracts ladybugs and spearmint attracts pirate and damsel bugs. Another option is to place some physical barrier between the bugs and plants, for instance a floating row cover, although care must be taken to remove such covers when the plants are flowering to allow for pollination. Other than these options, the best way to deal with bugs in your garden is just to make sure your plants stay as healthy as possible through proper watering and use of fertilizer as a healthy plant deals better with bugs.","title":"bugs"],["_id":["$oid":"5f8c6e7bc7a33e9aa8d50fed"],"references":"https://www.almanac.com/video/perfect-compost-recipe-how-get-your-compost-heap-cooking","text":"Composting is a great way to help your garden while being environmentally conscious at the same time. Turn your food waste, grass clippings, fallen leaves and more into food for your plants. The key to making the best compost is the correct ratio of `greens`, `browns`, and water. Greens are compost ingredients that are high in nitrogen, examples include grass clippings, food waste, and weeds. Avoid putting animal products (although egg shells are ok) or fats/oils into your compost. Browns are lower ingredients that are lower in nitrogen, common examples include fallen leaves, wood chips, and sawdust. The finer the material the faster the compost will form, so wood chips should be shredded if possible. Ideally your compost pile will have 2-3 parts browns to greens, which often causes finding enough browns to be a challenge. Finally, watering your compost pile speeds up the decomposition. Aim for a moist but not soggy pile. Now all there`s left to do is wait and let nature take its course until you are rewarded with some quality home-grown compost to feed your plants with!","title":"composting"],["_id":["$oid":"5f8c6e80c7a33e9aa8d50fee"],"references":"https://savvygardening.com/fertilizer-numbers/","text":"Fertilizer is a slightly more advanced, although not incredibly complicated, way to improve the care of your plants. The core idea behind fertilizing is to achieve the optimal levels of Nitrogen, Phosphorus, and Potassium in your soil, which is done by selecting fertilizer with the correct N-P-K (Nitrogen, Phosphorus, and Potassium) ratio for your garden. The best way to determine the content of your soil is to send a sample away to a laboratory, but generally Nitrogen promotes construction of chlorophyll (which allows plants to photosynthesize), Phosphorus promotes root growth, and Potassium increases a plant`s durability and vigor.","title":"fertilizer"],["_id":["$oid":"5f8c6e87c7a33e9aa8d50fef"],"references":"https://www.thespruce.com/what-is-mulch-1402413;https://www.goodhousekeeping.com/home/gardening/a20706549/how-to-mulch-your-garden/","text":"The purpose of mulch is multifold, but generally it consists of increasing retention of water in the soil, supression of weeds by severing their connection with the sun, controlling the temperature of the soil, and of course aiding the aesthetics of your garden. Lots of types of mulch exist, but their base material is usually compost, straw, hay, wood chips, or grass clippings. In general mulch is best used simply by spreading a 2-4 inch layer over top of the already-weeded soil in your garden.","title":"mulch"],["_id":["$oid":"5f8c6e94c7a33e9aa8d50ff0"],"references":"https://www.almanac.com/content/pruning-guide-trees-shrubs","text":"Pruning -- not just for aesthetics -- is the removal of dead and overgrown branches and stems in order to promote growth and fruitfulness. Many different kinds of plants can benefit from pruning, and the best way to identify what to prune is to look for yellow and brown sections on the plant to trim. Careful not to overprune though. When in doubt simply let the plant be, pruning is a less essential facet of gardenening when compared with water and light.","title":"pruning"],["_id":["$oid":"5f8c6e9bc7a33e9aa8d50ff1"],"text":"Different plants require very different levels of both light intensity and light duration, ranging from indoor plants like ferns that require little sun to outdoor plants like sunflowers that love the sun. While both light intensity and light duration are important, it turns out that the latter has a greater impact on the growing conditions of the plant. Our app allows you both to input the light duration for each plant in your garden, as well as to measure the intensity of sunlight to best help you plan out where to place each plant.","title":"sunlight"],["_id":["$oid":"5f8c6ebac7a33e9aa8d50ff2"],"references":"https://www.almanac.com/content/when-water-your-vegetable-garden-watering-chart","text":"Watering is a critical component of gardening and is often the cause of problems among novice gardeners. The best way to determine whether or not it`s time to water your plants it to physically check the soil`s moisture. While specific plants may require more specialized care, if the soil feels dry to you then you should water it. If, on the other hand, you find your soiling to be excessively damp, considering waiting to add more water until the soil has dried. Ideally watering should take place in the morning so that the foliage dries off quicker as wet foliage is a potential source of plant disease.","title":"watering"],["_id":["$oid":"5f8c6edfc7a33e9aa8d50ff3"],"references":"https://www.almanac.com/content/weed-control-techniques;https://www.almanac.com/video/keep-weeds-under-control-without-weed-killers","text":"There are several tricks in a prepared gardeners tool box to deal with weeds, but foremost is determination to pull them out. The goal here is simply to uproot the weed so that it can`t grow back. Other techniques that can help with weeding include mulching to block weeds from the sun, cover crops like barley and clover, and minimizing the disruption of your soil.","title":"weeding"],["_id":["$oid":"5f8c6efbc7a33e9aa8d50ff4"],"references":"https://www.almanac.com/content/plant-hardiness-zones","text":"It`s important to know your USDA hardiness zone so that you can identify which plants can be grown in your location. There are 13 USDA plant hardiness zones, visit the USDA website (https://planthardiness.ars.usda.gov/PHZMWeb/Default.aspx) to find which zone you`re in. Once you know your zone, you can then refer to guides for specific plants to see what zones they thrive in and determine whether or not you can grow them.","title":"zones"]]


    @IBOutlet var guideTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        guideTableView.delegate = self
        guideTableView.dataSource = self
        
        refreshControl.addTarget(self, action: #selector(self.handleRefresh(_:)), for: UIControl.Event.valueChanged)
        refreshControl.attributedTitle = NSAttributedString(string: "Checking for more guides ...")
        
        guideTableView.addSubview(refreshControl)
        self.refreshControl.beginRefreshing() //purely cosmetic refresh
        getGuides() //endrefresh is inside getGuides
        
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.refreshControl.beginRefreshing()
        getGuides()
//        refreshControl.endRefreshing()
        run(after: 0.5) {
            self.refreshControl.endRefreshing()
            DispatchQueue.main.async { self.guideTableView.reloadData() }
        }
    }
    
//    https://guides.codepath.com/ios/Using-UIRefreshControl
    func run(after wait: TimeInterval, closure: @escaping () -> Void) {
        let queue = DispatchQueue.main
        queue.asyncAfter(deadline: DispatchTime.now() + wait, execute: closure)
    }
    
    
    func getGuides() {
        print("GETTING GUIDES")
        let requestURL = "http://192.81.216.18/api/v1/guides/"
        var request = URLRequest(url: URL(string: requestURL)!)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let _ = data, error == nil else {
                print("NETWORKING ERROR")
                DispatchQueue.main.async {
                    self.run(after: 0.5) {
                        self.refreshControl.endRefreshing()
                    }
                }
                return
            }
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("HTTP STATUS: \(httpStatus.statusCode)")
                DispatchQueue.main.async {
                    self.run(after: 0.5) {
                        self.refreshControl.endRefreshing()
                    }
                }
                return
            }
            
            do {
    //            self.chatts = [Chatt]()
                let json = try JSONSerialization.jsonObject(with: data!) as! [[String:Any]]
//                print(json)
//                print(self.guides)
                self.guides = json
//                print(self.guides)
                self.run(after: 0.5) {
                    DispatchQueue.main.async {
                        self.guideTableView.reloadData()
                        self.refreshControl.endRefreshing()
                    }
                }
            } catch let error as NSError {
                print(error)
            }
        }
        task.resume()
    }
    
//    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
//        getGuides()
//    }
}



extension guideTable: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Tapped")
//        print(guides)
//        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
//        let destination = storyboard.instantiateViewController(withIdentifier: "thisGuide")
//        navigationController?.pushViewController(destination, animated: true)
        let guidePage = storyboard?.instantiateViewController(identifier: "guidePage") as? guidePage
        
        let title = guides[indexPath.row]["title"]
        var titleString = "Unnamed Guide"
        if case Optional<Any>.none = title {
            // is nil
        } else {
            // not nil
            titleString = String(describing: title!)
        }
        
        let text = guides[indexPath.row]["text"]
        var textString = "Guide is currently unavailable, sorry"
        if case Optional<Any>.none = text {
            //nil
        } else {
            //not nil
            textString = String(describing: text!)
        }
        
        let reference = guides[indexPath.row]["references"]
        var referenceString = ""
        if case Optional<Any>.none = reference {
            // is nil
        } else {
            // not nil
            referenceString = String(describing: reference!)
        }
        
        
//        let referenceString = String(describing: reference!)
//        if let reference = reference, !reference.isEmpty {
//            /* string is not blank */
//        }
        
        guidePage?.toTitle = titleString
        
        if referenceString == "" {
            guidePage?.guideBody = textString + "\n\nReferences: based off of the experience of the author"
        } else {
            guidePage?.guideBody = textString + "\n\nReferences: " + referenceString
        }
        
        self.navigationController?.pushViewController(guidePage!, animated: true)
        tableView.deselectRow(at: indexPath, animated: false)
//        performSegue(withIdentifier: "guideSegue", sender: self)

    }
}


extension guideTable: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return guides.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "guideCell", for: indexPath)
        
        
        let title = guides[indexPath.row]["title"]
        let titleString = String(describing: title!)
        if titleString == "" {
            cell.textLabel?.text = ""
        } else {
            cell.textLabel?.text = "guide to " + titleString
        }
        
        
        return cell
    }
}
