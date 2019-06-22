pragma solidity ^0.5.1;
pragma experimental ABIEncoderV2;


contract Ticketing {

    struct Trip {
        uint startTimestamp;
        uint endTimestamp;
        address payable transporter;
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

    struct Sponsorship {
        uint cashBackPercentage;
        uint amount;
    }

    uint PERCENTAGE_CONVERSION_BASE = 10000;

    mapping(address => Passenger) public passengers;

    mapping(address => Sponsorship[]) cashBacks;

    event TripCreated(
        uint startTimestamp,
        uint endTimestamp,
        address payable transporter,
        address passenger,
        bool isCheckedOut,
        bool isPaid,
        uint price
    );

    event CheckedOut(
        uint tripIndex,
        uint startTimestamp,
        uint endTimestamp,
        address payable transporter,
        address passenger
    );

    event TripPriceSet(
        uint tripIndex,
        uint price,
        address payable transporterAddress,
        address passengerAddress
    );


    function getPassenger(address passengerAddress) public view returns (Passenger memory) {
        return passengers[passengerAddress];
    }


    function getTrips(address passengerAddress) public view returns (Trip[] memory) {
        return passengers[passengerAddress].trips;
    }

    function getTrips(
        address passengerAddress,
        uint tripIndex
    ) public view returns (Trip memory) {
        return passengers[passengerAddress].trips[tripIndex];
    }


    function checkIn(
        address payable transporterAddress
    ) public {
        if (passengers[msg.sender].isCheckedIn) {
            revert("already checked in");
        }
        
        Trip memory trip = Trip({
            startTimestamp : now,
            endTimestamp : 0,
            transporter : transporterAddress,
            passenger : msg.sender,
            isCheckedOut : false,
            isPaid : false,
            price : 0
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

    function checkOut() public {
        Passenger storage passenger = passengers[msg.sender];
        if (!passenger.isCheckedIn) {
            revert("you're not checked in");
        }
        Trip[] memory trips = passenger.trips;
        Trip storage trip = passenger.trips[trips.length - 1];
        trip.isCheckedOut = true;
        trip.endTimestamp = now;

        passenger.isCheckedIn = false;
        passenger.checkedInTspKey = address(0);

        uint tripIndex = trips.length - 1;
        emit CheckedOut(
            tripIndex,
            trip.startTimestamp,
            trip.endTimestamp,
            trip.transporter,
            trip.passenger
        );
    }

    function setPrice(
        address passengerAddress,
        uint price,
        uint tripStartTimestamp
    ) public {
        Passenger storage passenger = passengers[passengerAddress];

        uint tripIndexLast = passenger.trips.length - 1;

        bool isTripMatched = false;
        for (uint i = tripIndexLast; i >= 0; i--) {
            Trip storage trip = passenger.trips[i];
            isTripMatched = (
                trip.isCheckedOut && 
                trip.isPaid == false &&
                trip.startTimestamp == tripStartTimestamp
            );
            if (isTripMatched) {
                Trip storage tripUnpaid = trip;
                bool isHasNoPermissionToSetPrice = msg.sender != trip.transporter;
                if (isHasNoPermissionToSetPrice) {
                    revert("only TSP can set the price");
                }
                tripUnpaid.price = price;

                uint tripIndex = i;
                address payable transporterAddress = msg.sender;
                emit TripPriceSet(
                    tripIndex,
                    price,
                    transporterAddress,
                    passengerAddress
                );
                break;
            }
            if (i == 0) {
                break;
            }
        }
        if (isTripMatched == false) {
            revert("no trip was matched");
        }
    }

    function payForTrip(uint tripIndex) public payable returns(uint) {
        Passenger storage passenger = passengers[msg.sender];
        Trip storage trip = passenger.trips[tripIndex];
        
        if (trip.price == 0 || trip.isPaid || trip.isCheckedOut == false) {
            revert("this trip isn't payable yet");
        }
        if (msg.value < trip.price) {
            revert("not enough money was sent");
        }
        
        uint priceNew = trip.price;
        
        Sponsorship[] storage sponsorshipArray = cashBacks[trip.transporter];
        
        for (uint i = 0; i < sponsorshipArray.length; i++) {
            Sponsorship memory sponsorship = sponsorshipArray[i];
            uint priceDiscount = (
                trip.price * (sponsorship.cashBackPercentage / PERCENTAGE_CONVERSION_BASE)
            );
            if (priceNew >= priceDiscount) {
                priceNew = priceNew - priceDiscount;
            } else {
                break;
            }
        }
        
        trip.isPaid = true;
        
        trip.transporter.transfer(msg.value);
        
        uint cashBackAmountInWei = trip.price - priceNew;
        return cashBackAmountInWei;
    }
    
    function sponsor(
        address transporterAddress,
        uint percentage
    ) public payable {
        Sponsorship memory sponsorship = Sponsorship({
            cashBackPercentage: percentage,
            amount: msg.value
        });
        cashBacks[transporterAddress].push(sponsorship);
    }
}
