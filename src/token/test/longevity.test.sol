pragma solidity ^0.8.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/longevity.sol";

contract TestLongevity {
    Longevity public longevity;

    // Run before every test function
    function beforeEach() public {
        longevity = new Longevity();
    }

    function testItGetVersion() public {
        Assert.equal(longevity.getVersion(), "0.1.0", "Version is correct");
    }

    function testItGetCurrentContestId() public {
        Assert.equal(
            longevity.getCurrentContestId(),
            "2022-01-17",
            "GetCurrentContestId working properly"
        );
    }

    function testItGetNextContestId() public {
        Assert.equal(
            longevity.getNextContestId(),
            "2022-01-18",
            "GetNextContestId working properly"
        );
    }

    function testItUploadImage() public {
        string memory imageId = "123";
        longevity.UploadImage(imageId);
    }

    function testItGetImageData() public {
        string memory imageId = "123";
        longevity.UploadImage(imageId);

        Assert.equal(
            longevity.getImageData(imageId).active,
            true,
            "Active is correct"
        );
        Assert.equal(
            longevity.getImageData(imageId).votes,
            0,
            "Votes is correct"
        );
        Assert.equal(
            longevity.getImageData(imageId).innapropriateVotes,
            0,
            "Innapropriate votes is correct"
        );

        longevity.InnapropriateVote(imageId);

        Assert.equal(
            longevity.getImageData(imageId).innapropriateVotes,
            1,
            "Inappropriate votes is correct"
        );
    }
}
