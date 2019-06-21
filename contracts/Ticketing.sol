pragma solidity ^0.5.0;


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

    constructor() public {
    }

    function createTrip(
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

    function getTrip(uint id) tripExists(id) public view
        returns(
         uint,
         uint,
         uint,
         string memory,
         string memory,
         bool,
         bool,
         uint,
    ) {
        return(
            id,
            tasks[id].start,
            tasks[id].end,
            tasks[id].transporter,
            tasks[id].passenger,
            tasks[id].is_checked_out,
            tasks[id].is_paid,
            tasks[id].price,
        );
    }


    modifier tripExists(uint id) {
        if(trips[id].id == 0) {
            revert();
        }
        _;
    }
}
