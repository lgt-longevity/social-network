// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./datetime.sol";

contract Longevity is ERC721 {
    string private currentContestId;
    string private nextContestId;
    DateTime private dateTimeUtils;
    uint256 private available;
    uint256 private count;

    uint256 private constant SUPPLY = 54000000000;
    uint256 private constant ONE_DAY = 24 * 60 * 60;

    event Logger(string msg);

    struct ImageUpload {
        address wallet;
        uint256 timestamp;
        uint256 votes;
        uint256 innapropriateVotes;
        bool active;
    }

    struct Winner {
        string imageId;
        address wallet;
    }

    mapping(string => mapping(string => ImageUpload)) private contests;
    mapping(string => Winner) private winners;

    constructor() ERC721("Longevity", "LGT") {
        count = 0;
        available = SUPPLY;
        dateTimeUtils = new DateTime();

        startDailyContests();
    }

    /* Modifiers */
    /*
    modifier restricted() {
        require(
            msg.sender == owner,
            "This function is restricted to the contract's owner"
        );
        _;
    }
    */

    // modifier restrictedPast24h(ImageUpload memory image) {
    //     require(
    //         image.timestamp + ONE_DAY < block.timestamp,
    //         "This function is restricted to not doing changes past 24 hours"
    //     );
    //     _;
    // }

    /* Getters */
    function getCurrentContestId() public view returns (string memory) {
        return currentContestId;
    }

    function getNextContestId() public view returns (string memory) {
        return nextContestId;
    }

    function getImageData(string memory imageId)
        public
        view
        returns (ImageUpload memory)
    {
        ImageUpload memory imageForCurrentContest = contests[currentContestId][
            imageId
        ];
        ImageUpload memory imageForNextContest = contests[nextContestId][
            imageId
        ];

        require(
            imageForCurrentContest.active || imageForNextContest.active,
            "Image doesn't exists"
        );

        if (imageForCurrentContest.active) {
            return imageForCurrentContest;
        } else {
            return imageForNextContest;
        }
    }

    function getVersion() public view returns (string memory) {
        return "0.1.8";
    }

    function getWinnerByDate(string memory date)
        public
        view
        returns (Winner memory)
    {
        return winners[date];
    }

    /* Utitilities */
    function convertStringDate2UIntTime(string memory date)
        private
        view
        returns (uint256)
    {}

    function convertUIntTime2StringDate(uint256 timestamp)
        private
        view
        returns (string memory)
    {
        return dateTimeUtils.getDate(timestamp);
    }

    /* Logical functions */

    function startDailyContests() private {
        currentContestId = dateTimeUtils.getDate(block.timestamp);
        nextContestId = dateTimeUtils.getDate(block.timestamp, 1);

        emit Logger("startDailyContests");
    }

    function createContest() private {
        uint16 year = dateTimeUtils.getYear(block.timestamp);
        uint8 month = dateTimeUtils.getMonth(block.timestamp);
        uint8 day = dateTimeUtils.getDay(block.timestamp);

        currentContestId = string(abi.encodePacked(year, "-", month, "-", day));
        nextContestId = string(
            abi.encodePacked(year, "-", month, "-", day + 1)
        );
    }

    function transfer(address wallet, uint256 qtd) private {
        payable(wallet).transfer(qtd);
    }

    function contestsLength() public view returns (uint256) {
        return count;
    }

    function UploadImage(string memory imageId) public returns (bool) {
        emit Logger("UploadImage > start");
        ImageUpload memory imageUpload = ImageUpload({
            wallet: msg.sender,
            timestamp: block.timestamp,
            votes: 0,
            innapropriateVotes: 0,
            active: true
        });

        contests[nextContestId][imageId] = imageUpload;
        count++;

        emit Logger("UploadImage > end");

        return true;
    }

    function Vote(string memory imageId) public {
        emit Logger("Vote > start");

        ImageUpload memory imageUploadForCurrentContest = contests[
            currentContestId
        ][imageId];
        ImageUpload memory imageUploadForNextContest = contests[nextContestId][
            imageId
        ];

        if (
            imageUploadForCurrentContest.active &&
            imageUploadForCurrentContest.timestamp + ONE_DAY >= block.timestamp
        ) {
            emit Logger("Vote > current contest");

            imageUploadForCurrentContest.votes++;
        }

        if (
            imageUploadForNextContest.active &&
            imageUploadForNextContest.timestamp + ONE_DAY >= block.timestamp
        ) {
            emit Logger("Vote > next contest");

            imageUploadForNextContest.votes++;
        }

        emit Logger("Vote > end");
    }

    function InnapropriateVote(string memory imageId) public {
        emit Logger("InnapropriateVote > start");

        ImageUpload memory imageUploadForCurrentContest = contests[
            currentContestId
        ][imageId];
        ImageUpload memory imageUploadForNextContest = contests[nextContestId][
            imageId
        ];

        if (
            imageUploadForCurrentContest.active &&
            imageUploadForCurrentContest.timestamp + ONE_DAY >= block.timestamp
        ) {
            emit Logger("InnapropriateVote > current contest");

            imageUploadForCurrentContest.innapropriateVotes++;
        }

        if (
            imageUploadForNextContest.active &&
            imageUploadForNextContest.timestamp + ONE_DAY >= block.timestamp
        ) {
            emit Logger("InnapropriateVote > next contest");

            imageUploadForNextContest.innapropriateVotes++;
        }

        emit Logger("InnapropriateVote > end");
    }
}
