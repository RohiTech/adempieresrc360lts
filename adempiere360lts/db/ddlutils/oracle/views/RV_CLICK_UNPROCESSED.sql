CREATE OR REPLACE VIEW RV_CLICK_UNPROCESSED
(W_CLICK_ID, AD_CLIENT_ID, AD_ORG_ID, ISACTIVE, CREATED, 
 CREATEDBY, UPDATED, UPDATEDBY, TARGETURL, REFERRER, 
 REMOTE_HOST, REMOTE_ADDR, USERAGENT, ACCEPTLANGUAGE, PROCESSED, 
 W_CLICKCOUNT_ID, AD_USER_ID, EMAIL)
AS 
SELECT W_CLICK_ID,AD_CLIENT_ID,AD_ORG_ID,ISACTIVE,CREATED,CREATEDBY,UPDATED,
UPDATEDBY,TARGETURL,REFERRER,REMOTE_HOST,REMOTE_ADDR,USERAGENT,ACCEPTLANGUAGE,
PROCESSED,W_CLICKCOUNT_ID,AD_USER_ID,EMAIL
FROM W_Click
WHERE W_ClickCount_ID IS NULL OR Processed='N';



