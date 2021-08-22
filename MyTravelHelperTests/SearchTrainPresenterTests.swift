//
//  SearchTrainPresenterTests.swift
//  MyTravelHelperTests
//
//  Created by Satish on 11/03/19.
//  Copyright © 2019 Sample. All rights reserved.
//

import XCTest
@testable import MyTravelHelper

class SearchTrainPresenterTests: XCTestCase {
    var presenter: SearchTrainPresenter!
    var view = SearchTrainMockView()
    var interactor = SearchTrainInteractorMock()
    
    override func setUp() {
      presenter = SearchTrainPresenter()
        presenter.view = view
        presenter.interactor = interactor
        interactor.presenter = presenter
    }

    func testfetchallStations() {
        presenter.fetchallStations()
        XCTAssertTrue(view.isSaveFetchedStatinsCalled)
    }
    
    /// Interactor testing
    func testTrainFromSourceAvailable() {
        /// Sending the sourcecode as FXFRD and Destionation code as "BALNA"
        interactor.fetchTrainsFromSource(sourceCode: "FXFRD", destinationCode: "BALNA")
        XCTAssertTrue(view.isTrainListUpdated)
    }
    
    override func tearDown() {
        presenter = nil
    }
}


class SearchTrainMockView:PresenterToViewProtocol {
    var isSaveFetchedStatinsCalled = false
    var isTrainListUpdated = false

    func saveFetchedStations(stations: [Station]?) {
        isSaveFetchedStatinsCalled = true
    }
    
    func checkTrainsAvailableFromSource(trainsList: [StationTrain]) -> Bool {
        return trainsList.count > 0 ? true : false
    }

    func showInvalidSourceOrDestinationAlert() {
        
    }
    
    func updateLatestTrainList(trainsList: [StationTrain]) {
        isTrainListUpdated = true
    }
    
    func showNoTrainsFoundAlert() {

    }
    
    func showNoTrainAvailbilityFromSource() {

    }
    
    func showNoInterNetAvailabilityMessage() {

    }
}

class SearchTrainInteractorMock:PresenterToInteractorProtocol {
    var presenter: InteractorToPresenterProtocol?
    var _sourceStationCode = String()
    var _destinationStationCode = String()

    func fetchallStations() {
        let station = Station(desc: "Belfast Central", latitude: 54.6123, longitude: -5.91744, code: "BFSTC", stationId: 228)
        presenter?.stationListFetched(list: [station])
    }
    
    /// This method gets the trains that are available from source stations.
    /// - Parameters:
    ///   - sourceCode: source station code
    ///   - destinationCode: destinaton station code
    func fetchTrainsFromSource(sourceCode: String, destinationCode: String) {
        _sourceStationCode = sourceCode
        _destinationStationCode = destinationCode
        var sourceTrainList = [StationTrain]()
        let sourceTrain = StationTrain(trainCode: "A868", fullName: "Foxford", stationCode: "FXFRD", trainDate: "22 Aug 2021", dueIn: 42, lateBy: 0, expArrival: "18:59", expDeparture: "")
        sourceTrainList.append(sourceTrain)
        self.proceesTrainListforDestinationCheck(trainsList: sourceTrainList)
    }
    
    /// This method gives the array of train movements  for the selected train
    /// - Returns: array of train movement object
    func getMockTrainmovements() -> [TrainMovement] {
        var trainMovements = [TrainMovement]()
        let destionationOne = TrainMovement(trainCode: "A868", locationCode: "MNLAJ", locationFullName: "Manulla Junction", expDeparture: "18:45:00")
        trainMovements.append(destionationOne)
        let destionationTwo = TrainMovement(trainCode: "A868", locationCode: "FXFRD", locationFullName: "Foxford", expDeparture: "18:59:30")
        trainMovements.append(destionationTwo)
        let destionationThree = TrainMovement(trainCode: "A868", locationCode: "BALNA", locationFullName: "Ballina", expDeparture: "00:00:00")
        trainMovements.append(destionationThree)
        return trainMovements
    }
    
    /// This method is responsible for forming the final user selected destination object (StationTrain)
    /// - Parameter trainsList: StationTrain object before finding destination
    func proceesTrainListforDestinationCheck(trainsList: [StationTrain]) {
        var _trainsList = trainsList
        let _movements = getMockTrainmovements()
        let sourceIndex = _movements.firstIndex(where: {$0.locationCode.caseInsensitiveCompare(self._sourceStationCode) == .orderedSame})
        let destinationIndex = _movements.firstIndex(where: {$0.locationCode.caseInsensitiveCompare(self._destinationStationCode) == .orderedSame})
        let desiredStationMoment = _movements.filter{$0.locationCode.caseInsensitiveCompare(self._destinationStationCode) == .orderedSame}
        let isDestinationAvailable = desiredStationMoment.count == 1

        if isDestinationAvailable  && sourceIndex! < destinationIndex! {
            _trainsList[0].destinationDetails = desiredStationMoment.first
        }
        presenter?.fetchedTrainsList(trainsList: _trainsList)
    }
}
