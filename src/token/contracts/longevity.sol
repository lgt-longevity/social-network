// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./datetime.sol";

contract Longevity is ERC721 {
    string private currentContestId;
    string private nextContestId;
    DateTime private dateTimeUtils;
    uint256 private available;

    uint256 private constant SUPPLY = 54000000000;
    uint256 private constant ONE_DAY = 24 * 60 * 60;

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

    struct ContestMetadata {
        string id;
        string date;
    }

    mapping(string => ContestMetadata) private contestsMetadata;
    mapping(string => mapping(string => ImageUpload)) private contests;
    mapping(string => Winner) private winners;

    constructor() ERC721("Longevity", "LGT") {
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
        return "0.1.0";
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

    function getContestIdentifierByTimestamp(uint256 timestamp)
        private
        view
        returns (ContestMetadata memory)
    {
        string memory id = convertUIntTime2StringDate(timestamp);

        return contestsMetadata[id];
    }

    function getContestIdentifierByDate(string memory date)
        private
        view
        returns (ContestMetadata memory)
    {
        string memory id = date;

        return contestsMetadata[id];
    }

    /* Logical functions */

    function startDailyContests() private {
        currentContestId = "2022-01-17"; //dateTimeUtils.getDate(block.timestamp);
        nextContestId = "2022-01-18"; //dateTimeUtils.getDate(block.timestamp, 1);
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

    function UploadImage(string memory imageId) public {
        ImageUpload memory imageUpload = ImageUpload({
            wallet: msg.sender,
            timestamp: block.timestamp,
            votes: 0,
            innapropriateVotes: 0,
            active: true
        });

        contests[nextContestId][imageId] = imageUpload;
    }

    function Vote(string memory imageId) public {
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
            imageUploadForCurrentContest.votes =
                imageUploadForCurrentContest.votes +
                1;
        }

        if (
            imageUploadForNextContest.active &&
            imageUploadForNextContest.timestamp + ONE_DAY >= block.timestamp
        ) {
            imageUploadForNextContest.votes =
                imageUploadForNextContest.votes +
                1;
        }
    }

    function InnapropriateVote(string memory imageId) public {
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
            imageUploadForCurrentContest.innapropriateVotes =
                imageUploadForCurrentContest.innapropriateVotes +
                1;
        }

        if (
            imageUploadForNextContest.active &&
            imageUploadForNextContest.timestamp + ONE_DAY >= block.timestamp
        ) {
            imageUploadForNextContest.innapropriateVotes =
                imageUploadForNextContest.innapropriateVotes +
                1;
        }
    }
}
