contract TontineOfKilpatrick {

    struct Nominee {
        address nomineeAddress;
        Member[] sponsors
    }

    struct Member {
        address memberAddress;
        bool isOnProbation;
        uint lastContribution;
        uint totalContribution;
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
        contributionInterbal = _contributionInterval;
        members[members.length] = Member(msg.sender, false, now, 0);
    }

    function nominateMember(address nomineeAddr) is membersOnly {
        nominees[nominees.length] = Nominee(nomineeAddr);
    }

    function voteForNominee(address nominee) {

    }

    function makePayment() is membersOnly {
        if(msg.amount != contribution) {
            throw;
        }

        Member member;
        if(member = findMember(msg.sender)) {
            member.lastContribution = now;
            member.totalContribution += msg.amount;
        }

    }

    function exitTontine() is membersOnly {
        Member member = findMember(msg.sender);
        member.memberAddress.call.value(member.totalContribution)();
        member.totalContribution = 0;
    }

    function findMember(address addr) {
        uint index = 0;
        while(index < members.length) {
            if(members[index].memberAddress == addr) {
                return members[index];;
            }
        }
        return false;
    }

    function findNominee(address addr) {
        uint index = 0;
        while(index < nominees.length) {
            if(nominees[index].nomineeAddress == addr) {
                return nominees[index];;
            }
        }
        return false;
    }

    function isMember(address addr) {
        uint index = 0;
        while(index < members.length) {
            if(members[index].memberAddress == addr) {
                return true;
            }
        }
        return false;
    }
}
