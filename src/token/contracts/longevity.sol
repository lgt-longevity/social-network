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
    uint256 private MINIMAL_INNAPROPRIATE_VOTES = 5;
    uint256 private MINIMAL_PERCENTAGE_INNAPROPRIATE_VOTES = 50;

    event Logger(string msg);

    struct Votation {
        bool like;
        bool innapropriate;
    }

    struct Image {
        address wallet;
        uint256 timestamp;
        mapping(string => Votation) votation;
        uint256 likeVotes;
        uint256 innapropriateVotes;
        bool active;
    }

    struct Winner {
        string imageId;
        address wallet;
    }

    string[] private currentContestImages;
    uint256 private currentContestImagesLength;
    string[] private nextContestImages;
    uint256 private nextContestImagesLength;
    mapping(string => mapping(string => Image)) private contests;
    mapping(string => Winner) private winners;

    constructor() ERC721("Longevity", "LGT") {
        currentContestImagesLength = 0;
        nextContestImagesLength = 0;

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

    // modifier restrictedPast24h(Image memory image) {
    //     require(
    //         image.timestamp + ONE_DAY < block.timestamp,
    //         "This function is restricted to not doing changes past 24 hours"
    //     );
    //     _;
    // }

    /** GETTERS */
    function getCurrentContestId() public view returns (string memory) {
        return currentContestId;
    }

    function getNextContestId() public view returns (string memory) {
        return nextContestId;
    }

    function getImageLikeVotes(string memory imageId)
        public
        view
        returns (uint256)
    {
        if (contests[currentContestId][imageId].active) {
            return contests[currentContestId][imageId].likeVotes;
        } else if (contests[nextContestId][imageId].active) {
            return contests[nextContestId][imageId].likeVotes;
        }

        return 0;
    }

    function getVersion() public view returns (string memory) {
        return "0.3.0";
    }

    function getWinnerByDate(string memory date)
        public
        view
        returns (Winner memory)
    {
        return winners[date];
    }

    /** UTILITIES */
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

    /* PRIVATE METHODS - BUSINESS LOGIC */
    function startDailyContests() private {
        currentContestId = dateTimeUtils.getDate(block.timestamp);
        nextContestId = dateTimeUtils.getDate(block.timestamp, 1);

        emit Logger("startDailyContests");
    }

    /** PUBLIC METHODS - API */
    function UploadImage(string memory imageId) public returns (bool) {
        emit Logger("UploadImage > start");

        Votation memory votation = Votation({
            like: false,
            innapropriate: false
        });

        Image memory image = Image({
            wallet: msg.sender,
            timestamp: block.timestamp,
            votation: votation,
            likeVotes: 0,
            innapropriateVotes: 0,
            active: true
        });

        nextContestImages.push(image);
        nextContestImagesLength++;
        contests[nextContestId][imageId] = image;

        emit Logger("UploadImage > end");

        return true;
    }

    function LikeVote(string memory imageId) public {
        emit Logger("LikeVote > start");

        Image memory imageForCurrentContest = contests[currentContestId][
            imageId
        ];
        Image memory imageForNextContest = contests[nextContestId][imageId];

        if (
            imageForCurrentContest.active &&
            imageForCurrentContest.timestamp + ONE_DAY >= block.timestamp
        ) {
            emit Logger("LikeVote > current contest");

            imageForCurrentContest.votes++;
            contests[currentContestId][imageId] = imageForCurrentContest;
        }

        if (
            imageForNextContest.active &&
            imageForNextContest.timestamp + ONE_DAY >= block.timestamp
        ) {
            emit Logger("LikeVote > next contest");

            imageForNextContest.votes++;

            contests[nextContestId][imageId] = imageForNextContest;
        }

        emit Logger("LikeVote > end");
    }

    function InnapropriateVote(string memory imageId) public {
        emit Logger("InnapropriateVote > start");

        Image memory imageForCurrentContest = contests[currentContestId][
            imageId
        ];
        Image memory imageForNextContest = contests[nextContestId][imageId];

        if (
            imageForCurrentContest.active &&
            imageForCurrentContest.timestamp + ONE_DAY >= block.timestamp
        ) {
            emit Logger("InnapropriateVote > current contest");

            imageForCurrentContest.innapropriateVotes++;

            contests[currentContestId][imageId] = imageForCurrentContest;
        }

        if (
            imageForNextContest.active &&
            imageForNextContest.timestamp + ONE_DAY >= block.timestamp
        ) {
            emit Logger("InnapropriateVote > next contest");

            imageForNextContest.innapropriateVotes++;

            contests[nextContestId][imageId] = imageForNextContest;
        }

        emit Logger("InnapropriateVote > end");
    }

    function CalculateWinnerDailyContest() public {
        emit Logger("CalculateWinnerDailyContest");

        startDailyContests();

        currentContestImages = nextContestImages;
        currentContestImagesLength = nextContestImagesLength;
        nextContestImages = [];
        nextContestImagesLength = 0;

        mapping(string => Image) memory currentContest = contests[
            currentContestId
        ];
        Image memory mostLikedImage = currentContest[currentContestImages[0]];

        for (uint256 i = 1; i < currentContestImages.lenght; i++) {
            if (
                mostLikedImage.votation.like <
                currentContest[currentContestImages[i]].votation.like &&
                (currentContest[currentContestImages[i]]
                    .votation
                    .innapropriate * 100) /
                    currentContest[currentContestImages[i]].votation.like >=
                MINIMAL_PERCENTAGE_INNAPROPRIATE_VOTES &&
                currentContest[currentContestImages[i]]
                    .votation
                    .innapropriate >=
                MINIMAL_INNAPROPRIATE_VOTES
            ) {}
        }
    }

    function transfer(address wallet, uint256 qtd) public {
        payable(wallet).transfer(qtd);
    }
}
