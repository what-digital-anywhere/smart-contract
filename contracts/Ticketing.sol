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
        address transporter
    ) public {
        Trip memory trip = Trip({
            startTimestamp: now,
            endTimestamp: 0,
            transporter: transporter,
            passenger: msg.sender,
            isCheckedOut: false,
            isPaid: false,
            price: 0
        });
        passengers[msg.sender].trips.push(trip);
        emit TripCreated(
            now,
            0,
            transporter,
            msg.sender,
            false,
            false,
            0
        );
    }

    function getTrips(address passenger) public view returns(Trip[] memory) {
        return passengers[passenger].trips;
    }
    
    function checkOut() public {
        Trip[] memory trips = passengers[msg.sender].trips;
        Trip storage trip = passengers[msg.sender].trips[trips.length - 1];
        trip.isCheckedOut = true;
        trip.endTimestamp = now;
        
        emit CheckedOut(
            trip.startTimestamp,
            trip.endTimestamp,
            trip.transporter,
            trip.passenger
        );
        
    }

}
