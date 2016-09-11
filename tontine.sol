pragma solidity ^0.4.1;

contract TontineOfKilpatrick {

    struct Nominee {
        address addr;
        Member[] sponsors;
        uint init;
    }

    struct Member {
        address addr;
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
        if(nominee.init == 1) throw;
        nominee.addr = nomineeAddr;
        nominee.init = 1;
        nominees.push(nominee);
    }

    function voteForNominee(address nomineeAddr) membersOnly {
        Nominee nominee = findNominee(nomineeAddr);
        nominee.sponsors[nominee.sponsors.length] = findMember(msg.sender);
        if(nominee.sponsors.length > members.length/2) {
            members[members.length] = Member(nominee.addr, false, now, 0, 1);
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
        member.addr.call.value(member.totalContribution)();
        member.totalContribution = 0;
    }

    function findMember(address addr) internal returns (Member storage) {
        uint index = 0;
        while(index < members.length) {
            if(members[index].addr == addr) {
                return members[index];
            }
        }
        Member x;
        return x;
    }

    function findNominee(address addr) internal returns (Nominee storage) {
        uint index = 0;
        while(index < nominees.length) {
            if(nominees[index].addr == addr) {
                return nominees[index];
            }
        }
        Nominee x;
        return x;
    }

    function isMember(address addr) returns (bool) {
        uint index = 0;
        while(index < members.length) {
            if(members[index].addr == addr) {
                return true;
            }
        }
        return false;
    }
}
