INSERT INTO issuingrules (
branchcode,categorycode,itemtype,restrictedtype,rentaldiscount,
reservecharge, fine, finedays, chargeperiod, accountsent, chargename, maxissueqty, issuelength,
allowonshelfholds, holdrestricted, holdspickupdelay, renewalsallowed, renewalperiod
)
SELECT  IF(branchcode='*','Default',branchcode),
        IF(categorycode='*','Default',categorycode),
        IF(itemtype='*','Default',itemtype),.
        restrictedtype,rentaldiscount,
        reservecharge, fine, finedays, chargeperiod,
        accountsent, chargename, maxissueqty, issuelength,
        allowonshelfholds, holdrestricted, holdspickupdelay,.
        renewalsallowed, renewalperiod
    FROM issuingrules where branchcode='*' or itemtype='*' or categorycode='*';

