var Ticketing = artifacts.require("./Ticketing.sol");


contract("Ticketing", function (accounts) {
    let passenger = accounts[0];
    let tsp = accounts[1];
    let sponsor = accounts[2];
    let sponsor2 = accounts[3];

    it("should decrease price by 40%", async function () {
        let contract = await Ticketing.deployed();

        await contract.checkIn(
            tsp, true,
            {from: passenger}
        );
        
        let tripData = await contract.getTrips(passenger);
        
        await contract.checkOut(
            true,
            {from: passenger}
        );
        
        let price30Dollars = '100000000000000000';
        await contract.setPrice(
            passenger, price30Dollars, tripData[0].startTimestamp,
            {from: tsp}
        );
        
        let percentage40 = 4000;
        let value60Dollars = '200000000000000000';
        await contract.sponsor(
            tsp, percentage40, {from: sponsor, value: value60Dollars}
        );
        
        let tripIndex = 0;
        let result = await contract.payForTrip.call(
            tripIndex, {from: passenger, value: price30Dollars}
        );
        if (parseInt(result) !== 40000000000000000) {
            throw Error();
        }
    });

    it("should decrease price by 40% + 20%", async function () {
        let contract = await Ticketing.deployed();

        await contract.checkIn(
            tsp, true,
            {from: passenger}
        );
        
        let tripData = await contract.getTrips(passenger);
        
        await contract.checkOut(
            true,
            {from: passenger}
        );
        
        let price30Dollars = '100000000000000000';
        await contract.setPrice(
            passenger, price30Dollars, tripData[0].startTimestamp,
            {from: tsp}
        );
        
        let percentage40 = 4000;
        let value60Dollars = '100000000000000000';
        await contract.sponsor(
            tsp, percentage40, {from: sponsor, value: value60Dollars}
        );
        
        let percentage20 = 2000;
        await contract.sponsor(
            tsp, percentage20, {from: sponsor2, value: value60Dollars}
        );
        
        let tripIndex = 0;
        let result = await contract.payForTrip.call(
            tripIndex, {from: passenger, value: price30Dollars}
        );
        console.log(parseInt(result));
    });

});
