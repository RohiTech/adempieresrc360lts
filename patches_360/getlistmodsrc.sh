:
# parameters likely to change
ROOTDIR=/home/carlos/srcAdempiere
MODULE=branches/globalqss/adempiere361
PATCHMOD=branches/globalqss/patches_360
MIGRATIONDIR=360lts-release
STARTREVISION=14066

# parameters unlikely to change
REPOSITORY=https://adempiere.svn.sourceforge.net/svnroot/adempiere
FINALREVISION=HEAD
BINDIR=$ROOTDIR/$MODULE/bin
TMPFILE=/tmp/lisjavafiles$$
TMPFILE2=/tmp/lisjavafiles2$$
TMPFILEDEL=/tmp/lisjavafiles_deleted_$$

> $TMPFILE

svn log --verbose --revision $STARTREVISION:$FINALREVISION $REPOSITORY/$MODULE |
grep "   [ADM] /$MODULE/.*\.java" |
fgrep -v "$MODULE/extend/src/test/functional" |  # Don't include functional test in patches
fgrep -v "$MODULE/base/src/org/compiere/model/MRoleTest.java" |  # Don't include MRoleTest test in patches
fgrep -v "$MODULE/posterita/src/main" |  # Don't include posterita changes in patches
fgrep -v "$MODULE/webCM/src/main/servlet" |  # Don't include webCM changes in patches
fgrep -v "$MODULE/sqlj/src" |  # Don't include sqlj changes in patches
while read ACTION FILE
do
    if [ x$ACTION = xM -o x$ACTION = xA ]
    then
        echo $ROOTDIR$FILE >> $TMPFILE
	sort -u -o $TMPFILE $TMPFILE
    elif [ x$ACTION = xD ]
    then
        echo $ROOTDIR$FILE >> $TMPFILEDEL
        fgrep -v -x $ROOTDIR$FILE $TMPFILE > $TMPFILE2
	mv $TMPFILE2 $TMPFILE
    else
        echo "Unknown ACTION on svn log : $ACTION $FILE"
    fi
done

echo "Modified not committed changes"
# Add modified not committed changes
cd $ROOTDIR/$MODULE
svn diff | grep "^Index: " | sed -e 's/^Index: //' |
grep "\.java" |
fgrep -v "$MODULE/extend/src/test/functional" |  # Don't include functional test in patches
fgrep -v "$MODULE/posterita/src/main" |  # Don't include posterita changes in patches
fgrep -v "$MODULE/sqlj/src" |  # Don't include sqlj changes in patches
while read FILE
do
    echo $ROOTDIR/$MODULE/$FILE
    echo $ROOTDIR/$MODULE/$FILE >> $TMPFILE
    sort -u -o $TMPFILE $TMPFILE
done

# Verify change
for FILEBRNCH in `cat $TMPFILE`
do
    FILEPTCH=`echo $FILEBRNCH | sed -e "s:/$MODULE/:/$PATCHMOD/:"`
    if [ -f $FILEBRNCH ]
    then
	# Show diffs
	diff -q $FILEBRNCH $FILEPTCH > /dev/null 2>&1
	if [ $? -ne 0 ]
	then
	    echo "***** $FILEBRNCH ****"
	    diff -b $FILEBRNCH $FILEPTCH
	fi
	# Synchronize
	DIRPTCH=`dirname $FILEPTCH`
	mkdir -p $DIRPTCH
	rsync -t -p -r  $FILEBRNCH $FILEPTCH
    fi
done

# cat $TMPFILE
# rm $TMPFILE
echo "**** Check deleted files ****"
cat $TMPFILEDEL

echo "**** Check jar files ****"
svn log --verbose --revision $STARTREVISION:$FINALREVISION $REPOSITORY/$MODULE |
grep "   [ADM] /$MODULE/.*\.jar"

echo "**** Check sqlj files ****"
svn log --verbose --revision $STARTREVISION:$FINALREVISION $REPOSITORY/$MODULE |
fgrep "$MODULE/sqlj/src"

TODAY=`date +%Y%m%d`
echo "MAIN_VERSION=3.6.0LTS+P$TODAY
DB_VERSION=`expr $TODAY : "\(....\)"`-`expr $TODAY : "....\(..\)"`-`expr $TODAY : "......\(..\)"`" > $ROOTDIR/$PATCHMOD/base/src/org/adempiere/version.properties

rsync $ROOTDIR/$MODULE/migration/$MIGRATIONDIR/oracle/*.sql $ROOTDIR/$PATCHMOD/migration/$MIGRATIONDIR/oracle
rsync $ROOTDIR/$MODULE/migration/$MIGRATIONDIR/postgresql/*.sql $ROOTDIR/$PATCHMOD/migration/$MIGRATIONDIR/postgresql
