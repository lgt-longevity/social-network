// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./datetime.sol";

contract Longevity is ERC721 {
    string private currentContestId;
    string private nextContestId;
    DateTime private dateTimeUtils;

    uint256 constant ONE_DAY = 24 * 60 * 60;

    struct ImageUpload {
        address wallet;
        uint256 timestamp;
        uint256 votes;
        uint256 innapropriateVotes;
    }

    struct Winner {
        string imageId;
        address wallet;
    }

    struct ContestMetadata {
        string id;
        string date;
    }

    mapping(string => ContestMetadata) public contestsMetadata;
    mapping(string => mapping(string => ImageUpload)) public contests;
    mapping(string => Winner) public winners;

    constructor() ERC721("Longevity", "LGT") {
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
        uint16 year = dateTimeUtils.getYear(timestamp);
        uint8 month = dateTimeUtils.getMonth(timestamp);
        uint8 day = dateTimeUtils.getDay(timestamp);

        return string(abi.encodePacked(year, "-", month, "-", day));
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

    function getContestDateWinner(string memory date)
        public
        view
        returns (Winner memory)
    {
        ContestMetadata memory contest = getContestIdentifierByDate(date);

        return winners[contest.id];
    }

    /* Logical functions */

    function startDailyContests() private {}

    function createContest() private {
        uint16 year = dateTimeUtils.getYear(block.timestamp);
        uint8 month = dateTimeUtils.getMonth(block.timestamp);
        uint8 day = dateTimeUtils.getDay(block.timestamp);

        currentContestId = string(abi.encodePacked(year, "-", month, "-", day));
        nextContestId = string(
            abi.encodePacked(year, "-", month, "-", day + 1)
        );
    }

    function UploadImage(string memory imageId) public {
        ImageUpload memory imageUpload = ImageUpload({
            wallet: msg.sender,
            timestamp: block.timestamp,
            votes: 0,
            innapropriateVotes: 0
        });

        contests[nextContestId][imageId] = imageUpload;
    }

    function Vote(string memory imageId) public {
        ImageUpload memory imageUploadForCurrentContest = contests[
            nextContestId
        ][imageId];
        ImageUpload memory imageUploadForNextContest = contests[nextContestId][
            imageId
        ];

        if (
            imageUploadForCurrentContest.timestamp + ONE_DAY >= block.timestamp
        ) {
            imageUploadForCurrentContest.votes =
                imageUploadForCurrentContest.votes +
                1;
        }

        if (imageUploadForNextContest.timestamp + ONE_DAY >= block.timestamp) {
            imageUploadForNextContest.votes =
                imageUploadForNextContest.votes +
                1;
        }
    }

    function InnapropriateVote(string memory imageId) public {
        ImageUpload memory imageUploadForCurrentContest = contests[
            nextContestId
        ][imageId];
        ImageUpload memory imageUploadForNextContest = contests[nextContestId][
            imageId
        ];

        if (
            imageUploadForCurrentContest.timestamp + ONE_DAY >= block.timestamp
        ) {
            imageUploadForCurrentContest.innapropriateVotes =
                imageUploadForCurrentContest.innapropriateVotes +
                1;
        }

        if (imageUploadForNextContest.timestamp + ONE_DAY >= block.timestamp) {
            imageUploadForNextContest.innapropriateVotes =
                imageUploadForNextContest.innapropriateVotes +
                1;
        }
    }
}
