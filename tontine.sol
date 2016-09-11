pragma solidity ^0.4.1;

contract TontineOfKilpatrick {

    struct Nominee {
        address addr;
        Member[] sponsors;
        uint alive;
    }

    struct Member {
        address addr;
        bool isOnProbation;
        uint lastContribution;
        uint totalContribution;
        uint alive;
    }

    Member[] members;
    Nominee[] nominees;

    uint livingMembers;
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
        livingMembers = livingMembers + 1;
    }

    function nominateMember(address nomineeAddr) membersOnly {
        Nominee nominee = findNominee(nomineeAddr);
        if(nominee.alive == 1) throw; // Nominee already added
        nominee.addr = nomineeAddr;
        nominee.alive = 1;
        nominees.push(nominee);
    }

    function voteForNominee(address nomineeAddr) membersOnly {
        Nominee nominee = findNominee(nomineeAddr);
        nominee.sponsors[nominee.sponsors.length] = findMember(msg.sender);
        if(nominee.sponsors.length > members.length/2) {
            members[members.length] = Member(nominee.addr, false, now, 0, 1);
            livingMembers = livingMembers + 1;
        }
    }

    function makePayment() membersOnly {
        if(msg.value != contribution) {
            throw;
        }
        
        Member member = findMember(msg.sender);

        // Member has missed more than two payment intervals, or is on probation
        // and has missed an additional payment interval
        if(now - (contributionInterval * 2) > member.lastContribution ||
           member.isOnProbation && now - contributionInterval >
           member.lastContribution) {
            removeMember(member);
            msg.sender.send(msg.value);
            return;
        }

        // Member is late on payment. Put them on probation.
        if(!member.isOnProbation &&
           now - contributionInterval > member.lastContribution &&
           now - contributionInterval * 2 < member.lastContribution) {
            member.isOnProbation = true; 
        }

        member.lastContribution = now;
        member.totalContribution += msg.value;

    }

    function exitTontine() membersOnly {
        Member memory member = findMember(msg.sender);
        member.addr.call.value(member.totalContribution)();
        member.totalContribution = 0;
        member.alive = 0;
        livingMembers = livingMembers - 1;
    }

    function removeMember(Member member) internal {
        member.alive = 0;
        livingMembers = livingMembers - 1;
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
