// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CareerIncentives {
    struct Question {
        uint id;
        string content;
        address askedBy;
        bool isAnswered;
    }

    struct Answer {
        uint questionId;
        string content;
        address answeredBy;
        uint votes; // Upvotes for the answer
    }

    address public admin;
    uint public questionCount;
    uint public answerCount;
    mapping(uint => Question) public questions;
    mapping(uint => Answer) public answers;
    mapping(address => uint) public tokenBalance;

    event QuestionAsked(uint questionId, string content, address askedBy);
    event AnswerSubmitted(uint answerId, uint questionId, string content, address answeredBy);
    event TokensRewarded(address recipient, uint tokens);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action.");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    function askQuestion(string memory _content) public {
        questionCount++;
        questions[questionCount] = Question(questionCount, _content, msg.sender, false);
        emit QuestionAsked(questionCount, _content, msg.sender);
    }

    function submitAnswer(uint _questionId, string memory _content) public {
        require(_questionId > 0 && _questionId <= questionCount, "Invalid question ID.");
        require(!questions[_questionId].isAnswered, "Question is already answered.");

        answerCount++;
        answers[answerCount] = Answer(_questionId, _content, msg.sender, 0);

        emit AnswerSubmitted(answerCount, _questionId, _content, msg.sender);
    }

    function markAsAnswered(uint _questionId, uint _answerId) public onlyAdmin {
        require(_questionId > 0 && _questionId <= questionCount, "Invalid question ID.");
        require(_answerId > 0 && _answerId <= answerCount, "Invalid answer ID.");
        require(answers[_answerId].questionId == _questionId, "Answer does not match question.");

        questions[_questionId].isAnswered = true;

        // Reward the answerer with tokens
        address recipient = answers[_answerId].answeredBy;
        tokenBalance[recipient] += 10; // Reward 10 tokens for each accepted answer
        emit TokensRewarded(recipient, 10);
    }

    function upvoteAnswer(uint _answerId) public {
        require(_answerId > 0 && _answerId <= answerCount, "Invalid answer ID.");
        answers[_answerId].votes++;
    }

    function getTokenBalance(address _user) public view returns (uint) {
        return tokenBalance[_user];
    }
}


