pragma solidity ^0.5.1;
pragma experimental ABIEncoderV2;

contract Ticketing {
    
    struct Trip {
        uint startTimestamp;
        uint endTimestamp;
        address transporter;
        address passenger;
        bool isCheckedOut;
        bool isPaid;
        uint price;
    }
    
    struct Passenger {
        bool isCheckedIn;
        address checkedInTspKey;
        Trip[] trips;
    }
    
    mapping (address => Passenger) public passengers;

    event TripCreated(
        uint startTimestamp,
        uint endTimestamp,
        address transporter,
        address passenger,
        bool isCheckedOut,
        bool isPaid,
        uint price
    );
    
    event CheckedOut(
        uint startTimestamp,
        uint endTimestamp,
        address transporter,
        address passenger
    );

    constructor() public {
    }

    function checkIn(
        address transporterAddress
    ) public {
        Trip memory trip = Trip({
            startTimestamp: now,
            endTimestamp: 0,
            transporter: transporterAddress,
            passenger: msg.sender,
            isCheckedOut: false,
            isPaid: false,
            price: 0
        });
        passengers[msg.sender].trips.push(trip);
        passengers[msg.sender].isCheckedIn = true;
        passengers[msg.sender].checkedInTspKey = transporterAddress;
        emit TripCreated(
            now,
            0,
            transporterAddress,
            msg.sender,
            false,
            false,
            0
        );
    }

    function getTrips(address passengerAddress) public view returns(Trip[] memory) {
        return passengers[passengerAddress].trips;
    }
    
    function checkOut() public {
        Passenger storage passenger = passengers[msg.sender];
        Trip[] memory trips = passenger.trips;
        Trip storage trip = passenger.trips[trips.length - 1];
        trip.isCheckedOut = true;
        trip.endTimestamp = now;
        
        passenger.isCheckedIn = false;
        passenger.checkedInTspKey = address(0);
        
        emit CheckedOut(
            trip.startTimestamp,
            trip.endTimestamp,
            trip.transporter,
            trip.passenger
        );
        
    }
//
//    function setPrice(address passengerAddress, unit price) public {
//        Passenger storage passenger = passengers[passengerAddress];
//        tripLast = passenger.trips;
//        
//        memory 
//        
//        for (uint i = passenger.trips.leng; i<studentList.length; i++) {
//            emit LogStudentGrade(studentList[i], studentStructs[studentList[i]].grade);
//        }
//
//    }
}
