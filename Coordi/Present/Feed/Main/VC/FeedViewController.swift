//
//  FeedViewController.swift
//  Coordi
//
//  Created by 차소민 on 4/25/24.
//
import UIKit
import Tabman
import Pageboy
import RxSwift
import RxCocoa
import WeatherKit
import CoreLocation

let temp = BehaviorRelay(value: 40)

final class FeedViewController: TabmanViewController {
    private let viewModel: FeedViewModel
    private let disposeBag = DisposeBag()
    
    private var viewControllers: [UIViewController]
    private let searchButton = UIBarButtonItem()
    
    private let weatherService = WeatherService()
    private let locationManager = CLLocationManager()
    
    init(viewModel: FeedViewModel, followFeedViewModel: FollowFeedViewModel, allFeedViewModel: AllFeedViewModel) {
        self.viewModel = viewModel
        self.viewControllers = [FollowFeedViewController(viewModel: followFeedViewModel),
                                AllFeedViewController(viewModel: allFeedViewModel)]
        super.init(nibName: nil, bundle: nil)
    }
    
    @available (*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTopTabBar()
        setLocation()
        configureView()
        bind()
    }
    
    deinit {
        locationManager.stopUpdatingLocation()
    }
    
    private func bind() {
        let input = FeedViewModel.Input(searchButtonTap: searchButton.rx.tap.asObservable(),
                                        temp: .init())
        let output = viewModel.transform(input: input)
        
        temp
            .bind(to: input.temp)
            .disposed(by: disposeBag)
        
        output.tempText
            .drive(with: self) { owner, text in
                owner.navigationItem.title = text
            }
            .disposed(by: disposeBag)
    }
    
    private func setTopTabBar() {
        self.dataSource = self
        let bar = TMBar.ButtonBar()
        bar.layout.transitionStyle = .snap
        bar.layout.alignment = .centerDistributed
        bar.layout.contentMode = .fit
        bar.buttons.customize { (button) in
            button.tintColor = .pointColor
            button.selectedTintColor = .pointColor
        }
        addBar(bar, dataSource: self, at: .top)
    }
    
    private func configureView() {
        searchButton.image = UIImage(systemName: "magnifyingglass")
        navigationItem.title = "현재 기온 알 수 없음"   // 기온 모를 때는 전체 보여주기 OR 텅뷰 만들어서 위치허용 유도하기
        navigationItem.rightBarButtonItem = searchButton
    }
}

extension FeedViewController: PageboyViewControllerDataSource, TMBarDataSource {
    func barItem(for bar: any Tabman.TMBar, at index: Int) -> any Tabman.TMBarItemable {
        if index == 0 {
            return TMBarItem(title: "팔로잉")
        } else {
            return TMBarItem(title: "탐색")
        }
    }
    
    func numberOfViewControllers(in pageboyViewController: Pageboy.PageboyViewController) -> Int {
        viewControllers.count
    }
    
    func viewController(for pageboyViewController: Pageboy.PageboyViewController, at index: Pageboy.PageboyViewController.PageIndex) -> UIViewController? {
        viewControllers[index]
    }
    
    func defaultPage(for pageboyViewController: Pageboy.PageboyViewController) -> Pageboy.PageboyViewController.Page? {
        nil
    }
}

extension FeedViewController {
    func getWeather(location: CLLocation) {
        Task {
            do {
                let weather = try await WeatherService.shared.weather(for: location)
                print("Temp: \(weather.currentWeather.temperature)")
                temp.accept(Int(weather.currentWeather.temperature.value))
                
                
            } catch {
                print("날씨 못 받아옴",String(describing: error.localizedDescription))
            }
        }
    }
}

extension FeedViewController: CLLocationManagerDelegate {
    func setLocation() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            print("Latitude: \(location.coordinate.latitude), Longitude: \(location.coordinate.longitude)")
            getWeather(location: location)

        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Error: \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            print("GPS 권한 설정됨")
        case .restricted, .notDetermined:
            print("GPS 권한 설정되지 않음")
            locationManager.requestWhenInUseAuthorization()
        case .denied:
            print("GPS 권한 요청 거부됨")
            locationManager.requestWhenInUseAuthorization()
        default:
            print("GPS: Default")
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
}

