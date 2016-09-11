pragma solidity ^0.4.1;

contract TontineOfKilpatrick {

    struct Nominee {
        address nomineeAddress;
        Member[] sponsors;
        uint init;
    }

    struct Member {
        address memberAddress;
        bool isOnProbation;
        uint lastContribution;
        uint totalContribution;
        uint init;
    }

    Member[] members;
    Nominee[] nominees;

    uint contribution;
    uint contributionInterval;

    modifier membersOnly() {
        if(!isMember(msg.sender)) throw;
        _;
    }

    function TontineOfKilpatrick(uint _contribution, uint _contributionInterval) {
        contribution = _contribution;
        contributionInterval = _contributionInterval;
        members[members.length] = Member(msg.sender, false, now, 0, 1);
    }

    function nominateMember(address nomineeAddr) membersOnly {
        Nominee nominee = findNominee(nomineeAddr);
        nominees[nominees.length] = nominee;
        nominees[nominees.length-1].nomineeAddress = nomineeAddr;
    }

    function voteForNominee(address nomineeAddr) membersOnly {
        Nominee nominee = findNominee(nomineeAddr);
        nominee.sponsors[nominee.sponsors.length] = findMember(msg.sender);
        if(nominee.sponsors.length > members.length/2) {
            members[members.length] = Member(nominee.nomineeAddress, false, now, 0, 1);
        }
    }

    function makePayment() membersOnly {
        if(msg.value != contribution) {
            throw;
        }

        Member memory member;
        if(isMember(msg.sender)) {
            member = findMember(msg.sender);
            member.lastContribution = now;
            member.totalContribution += msg.value;
        }

    }

    function exitTontine() membersOnly {
        Member memory member = findMember(msg.sender);
        member.memberAddress.call.value(member.totalContribution)();
        member.totalContribution = 0;
    }

    function findMember(address addr) internal returns (Member storage) {
        uint index = 0;
        while(index < members.length) {
            if(members[index].memberAddress == addr) {
                return members[index];
            }
        }
        Member x;
        return x;
    }

    function findNominee(address addr) internal returns (Nominee storage) {
        uint index = 0;
        while(index < nominees.length) {
            if(nominees[index].nomineeAddress == addr) {
                return nominees[index];
            }
        }
        Nominee x;
        return x;
    }

    function isMember(address addr) returns (bool) {
        uint index = 0;
        while(index < members.length) {
            if(members[index].memberAddress == addr) {
                return true;
            }
        }
        return false;
    }
}
