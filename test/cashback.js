var Ticketing = artifacts.require("./Ticketing.sol");


contract("Ticketing", function (accounts) {
    let passenger = accounts[0];
    let tsp = accounts[1];
    let sponsor = accounts[2];


    it("should put 10000 MetaCoin in the first account", async function () {
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
        
        let price30Dollars = 100000000000000000;
        await contract.setPrice(
            passenger, price30Dollars, tripData[0].startTimestamp,
            {from: tsp}
        )

    });

});