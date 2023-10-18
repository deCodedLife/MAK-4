#include <QApplication>
#include <QQmlApplicationEngine>

#include <configs.h>

#include <net-snmp/net-snmp-config.h>
#include <net-snmp/net-snmp-includes.h>
#include <string.h>

#define HOST "185.51.21.124:16190"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    QQmlApplicationEngine engine;

    QJsonObject config;

    Configs cfg = Configs();
    cfg.Read( &config );

    if ( config.isEmpty() )
    {
        config = Configs::Default();
        cfg.Write( config );
    }

    qDebug() << config;

    netsnmp_pdu *pdu;
    netsnmp_pdu *response;

    oid anOID[MAX_OID_LEN];
    size_t anOID_len;

    netsnmp_variable_list *vars;
    int status;
    int count=1;

    init_snmp("MAK-4");

    snmp_session session, *ss;
    snmp_sess_init(&session);

    session.version = SNMP_VERSION_2c;
    session.community = (u_char *) "public";
    session.community_len = strlen("public");
    session.peername = strdup(HOST);
    session.remote_port = (u_short) '16190';

//    session.peername = HOST;

//    session.securityName = strdup( "MD5User" );
//    session.securityNameLen = strlen( "MD5User" );

//    session.securityAuthKey = "";

//    session.securityLevel = SNMP_SEC_LEVEL_AUTHPRIV;
//    session.securityAuthProto = (oid *) netsnmp_memdup(
//        usmAESPrivProtocol,
//        sizeof(usmAESPrivProtocol)
//    );
//    session.securityAuthProtoLen = sizeof( usmAESPrivProtocol ) / sizeof( oid );
//    session.securityAuthKeyLen = USM_AUTH_KU_LEN;

//    session.securityPrivProto = (oid *) netsnmp_memdup(
//        usmAESPrivProtocol,
//        sizeof(usmAESPrivProtocol)
//    );
//    session.securityPrivProtoLen = sizeof( usmAESPrivProtocol ) / sizeof( oid );

    /*if ( generate_Ku(session.securityAuthProto,
                    session.securityAuthProtoLen,
                    (const u_char *) "0000000001",
                    strlen("0000000001"),
                    session.securityAuthKey,
                    &session.securityAuthKeyLen
    ) != SNMPERR_SUCCESS) {
        snmp_perror(argv[0]);
        snmp_log(LOG_ERR,
                 "Error generating Ku from authentication pass phrase. \n");
        exit(1);
    }*/

    SOCK_STARTUP;

    ss = snmp_open(&session);

    if (!ss) {
        snmp_sess_perror("ack", &session);
        SOCK_CLEANUP;
        exit(1);
    }

    pdu = snmp_pdu_create(SNMP_MSG_GET);
    anOID_len = MAX_OID_LEN;
    if (!snmp_parse_oid("1.3.6.1.4.1.36032.1.10.8.1.0", anOID, &anOID_len)) {
        snmp_perror("1.3.6.1.4.1.36032.1.10.8.1.0");
        SOCK_CLEANUP;
        exit(1);
    }

    read_objid("1.3.6.1.4.1.36032.1.10.8.1.0", anOID, &anOID_len);
    get_node("sysDescr.0", anOID, &anOID_len);
    read_objid("system.sysDescr.0", anOID, &anOID_len);

    status = snmp_synch_response(ss, pdu, &response);

    if (status == STAT_SUCCESS && response->errstat == SNMP_ERR_NOERROR) {
        /*
       * SUCCESS: Print the result variables
       */
        printf( "Yeeeeeah\n" );

        for(vars = response->variables; vars; vars = vars->next_variable)
            print_variable(vars->name, vars->name_length, vars);

        /* manipuate the information ourselves */
        for(vars = response->variables; vars; vars = vars->next_variable) {
            if (vars->type == ASN_OCTET_STR) {
                char *sp = (char *)malloc(1 + vars->val_len);
                memcpy(sp, vars->val.string, vars->val_len);
                sp[vars->val_len] = '\0';
                printf("value #%d is a string: %s\n", count++, sp);
                free(sp);
            }
            else
                printf("value #%d is NOT a string! Ack!\n", count++);
        }
    } else {
        /*
       * FAILURE: print what went wrong!
       */

        if (status == STAT_SUCCESS)
            fprintf(stderr, "Error in packet\nReason: %s\n",
                    snmp_errstring(response->errstat));
        else if (status == STAT_TIMEOUT)
            fprintf(stderr, "Timeout: No response from %s.\n",
                    session.peername);
        else
            snmp_sess_perror("snmpdemoapp", ss);

    }


    engine.load(QUrl(QStringLiteral("qrc:/qml/Main.qml")));
    return app.exec();
}
