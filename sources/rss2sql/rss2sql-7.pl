#!/usr/bin/perl
#
#    Copyright (C) 2008,2009,2010 Guylhem
#
#    This program is free software: you can redistribute it and/or
#    modify it under the terms of the GNU Affero General Public License
#    as published by the Free Software Foundation, either version 3 of
#    the License, or (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public
#    License along with this program.  If not, see
#    <http://www.gnu.org/licenses/>.

use DBI;

#use warnings;
#use strict;
#use Data::Dumper; #uncomment for debugging

sub mysubstr {
    my $out = substr( $_[0], $_[1], $_[2] );
    $out =~ s/ //g;
    if ( length($out) == 0 ) { $out = "DEFAULT"; }
    return $out;
}

unless ( scalar @ARGV == 2 ) {
    die "Usage:\n\t$0 RSS.grp annee\n";
}

$infile = $ARGV[0];
$annee  = $ARGV[1];

open( IFD, "<$infile" ) or die( "Can't read input file " . $infile . " !\n" );

$line_cur = 0;
while ( $rss_line = <IFD> ) {

    # commencer par lire la version de RSS pour parser diff�remment

    $version_groupage = mysubstr( $rss_line, 0, 2 );
    $cmd              = mysubstr( $rss_line, 2, 2 );
    $ghm              = mysubstr( $rss_line, 4, 4 );
    $filler           = mysubstr( $rss_line, 8, 1 );
    $version_rss      = mysubstr( $rss_line, 9, 3 );

    if ( $version_rss == 111 ) {
        if ( $schema_sql != 1 ) {
            print "drop table rss_$annee cascade;
drop table rss_diags_$annee cascade;
drop table rss_actes_$annee cascade;

create table rss_$annee (
 code_sq_pk SERIAL PRIMARY KEY,
 annee char(15),
 version_groupage smallint,
 cmd char(4),
 ghm char(6),
 filler char(1),
 version_rss smallint,
 code_retour smallint,
 finess char(10),
 version_rum smallint,
 rss int,
 iep int,
 ddn timestamp,
 sexe char(1),
 uf smallint,
 uf_autorisation smallint,
 lit_autorisation smallint,
 reserve1 smallint,
 date_entree_uf timestamp,
 entree smallint,
 provenance smallint,
 date_sortie_uf timestamp,
 sortie smallint,
 destination smallint,
 cp_residence int,
 poids_nne_entree int,
 sceances_nbr smallint,
 das_nbr smallint,
 dad_nbr smallint,
 actes_nbr smallint,
 dp char(9),
 dr char(9),
 igs2 smallint,
 reserve2 char(16)
);

create table rss_diags_$annee (
 code_sq_fk INT,
 rss int,
 iep int,
 das char(9),
 dad char(9),
 FOREIGN KEY (code_sq_fk) REFERENCES rss_$annee (code_sq_pk) ON DELETE CASCADE ON UPDATE CASCADE
);

create table rss_actes_$annee (
 code_sq_fk INT,
 rss int,
 iep int,
 date_acte timestamp,
 code_ccam char(8),
 phase smallint,
 activite smallint,
 ext_doc smallint,
 modificateur char(9),
 remb_exceptionnel char(9),
 assoc_nonprevue smallint,
 iteration smallint,
 FOREIGN KEY (code_sq_fk) REFERENCES rss_$annee (code_sq_pk) ON DELETE CASCADE ON UPDATE CASCADE
);
";
            $schema_sql = 1;
        }
        $code_retour      = mysubstr( $rss_line, 12,  3 );
        $finess           = mysubstr( $rss_line, 15,  9 );
        $version_rum      = mysubstr( $rss_line, 24,  3 );
        $rss              = mysubstr( $rss_line, 27,  7 );
        $iep              = mysubstr( $rss_line, 34,  20 );
        $ddn              = mysubstr( $rss_line, 54,  8 );
        $sexe             = mysubstr( $rss_line, 62,  1 );
        $uf               = mysubstr( $rss_line, 63,  4 );
        $uf_autorisation  = mysubstr( $rss_line, 67,  2 );
        $lit_autorisation = mysubstr( $rss_line, 69,  2 );
        $reserve1         = mysubstr( $rss_line, 71,  1 );
        $date_entree_uf   = mysubstr( $rss_line, 72,  8 );
        $entree           = mysubstr( $rss_line, 80,  1 );
        $provenance       = mysubstr( $rss_line, 81,  1 );
        $date_sortie_uf   = mysubstr( $rss_line, 82,  8 );
        $sortie           = mysubstr( $rss_line, 90,  1 );
        $destination      = mysubstr( $rss_line, 91,  1 );
        $cp_residence     = mysubstr( $rss_line, 92,  5 );
        $poids_nne_entree = mysubstr( $rss_line, 97,  4 );
        $sceances_nbr     = mysubstr( $rss_line, 101, 2 );
        $das_nbr          = mysubstr( $rss_line, 103, 2 );
        $dad_nbr          = mysubstr( $rss_line, 105, 2 );
        $actes_nbr        = mysubstr( $rss_line, 107, 2 );
        $dp               = mysubstr( $rss_line, 109, 8 );
        $dr               = mysubstr( $rss_line, 117, 8 );
        $igs2             = mysubstr( $rss_line, 125, 3 );
        $reserve2         = mysubstr( $rss_line, 128, 15 );

        # Maintenant on parse le rss_line selon le nbr DAS/DAD/ACTES
        $offset = 143;

        if ( $das_nbr > 0 ) {
            $das_cur = 0;
            while ( $das_cur < $das_nbr ) {
                $das[$das_cur] = mysubstr( $rss_line, $offset, 8 );
                $offset = $offset + 8;
                $das_cur++;
            }    # while das_cur
        }    # das_nbr
        if ( $dad_nbr > 0 ) {
            $dad_cur = 0;
            while ( $dad_cur < $dad_nbr ) {
                $dad[$dad_cur] = mysubstr( $rss_line, $offset, 8 );
                $offset = $offset + 8;
                $dad_cur++;
            }    # while dad_cur
        }    # dad_nbr

        if ( $actes_nbr > 0 ) {
            $actes_cur = 0;
            while ( $actes_cur < $actes_nbr ) {
                $acte_date[$actes_cur] = mysubstr( $rss_line, $offset, 8 );
                $acte_code_ccam[$actes_cur] =
                  mysubstr( $rss_line, $offset + 8, 7 );
                $acte_phase[$actes_cur] =
                  mysubstr( $rss_line, $offset + 8 + 7, 1 );
                $acte_activite[$actes_cur] =
                  mysubstr( $rss_line, $offset + 8 + 7 + 1, 1 );
                $acte_ext_doc[$actes_cur] =
                  mysubstr( $rss_line, $offset + 8 + 7 + 1 + 1, 1 );
                $acte_modificateur[$actes_cur] =
                  mysubstr( $rss_line, $offset + 8 + 7 + 1 + 1 + 1, 4 );
                $acte_remb_exceptionnel[$actes_cur] =
                  mysubstr( $rss_line, $offset + 8 + 7 + 1 + 1 + 1 + 4, 1 );
                $acte_assoc_nonprevue[$actes_cur] =
                  mysubstr( $rss_line, $offset + 8 + 7 + 1 + 1 + 1 + 4 + 1, 1 );
                $acte_iteration[$actes_cur] =
                  mysubstr( $rss_line, $offset + 8 + 7 + 1 + 1 + 1 + 4 + 1 + 1,
                    2 );

                $offset = $offset + 26;
                $actes_cur++;
            }    # while actes_cur
        }    # actes_nbr

        # on est normalement � la fin de la ligne

# maintenant que la ligne est lue, faut l'ins�rrer dans la base
#  	$dbh = DBI->connect("dbi:Pg:dbname=chu;host=localhost;port=5432", 'postgres', 'postgres', {AutoCommit => 0}) or die ("Can't connect to the database!\n");

        # On rearrage les dates au format iso
        $date_entree_uf =~ s{(.{2})(.{2})(.{4})}{\3-\2-\1};
        $date_sortie_uf =~ s{(.{2})(.{2})(.{4})}{\3-\2-\1};
        $ddn            =~ s{(.{2})(.{2})(.{4})}{\3-\2-\1};

# prepare and execute query
# pas de placeholder car perl est weakly-typed, ce qui pose des probl�mes de reconnaissance des types de values
        $sql =
"INSERT into rss_$annee (annee, version_groupage, cmd, ghm, filler, version_rss, code_retour, finess, version_rum, rss, iep, ddn, sexe, uf, uf_autorisation, lit_autorisation, reserve1, date_entree_uf, entree, provenance, date_sortie_uf, sortie, destination, cp_residence, poids_nne_entree, sceances_nbr, das_nbr, dad_nbr, actes_nbr, dp, dr, igs2, reserve2) values ('$annee', $version_groupage, '$cmd', '$ghm', $filler, $version_rss, $code_retour, '$finess', $version_rum, $rss, $iep, '$ddn', '$sexe', $uf, $uf_autorisation, $lit_autorisation, $reserve1, '$date_entree_uf', $entree, $provenance, '$date_sortie_uf', $sortie, $destination, $cp_residence, $poids_nne_entree, $sceances_nbr, $das_nbr, $dad_nbr, $actes_nbr, '$dp', '$dr', $igs2, $reserve2);";
        print $sql . "\n";
        $sql = "select currval('rss_" . $annee . "_code_sq_pk_seq') as transmis;";
        print $sql . "\n";

        if ( $das_nbr > 0 ) {
            $das_cur = 0;
            while ( $das_cur < $das_nbr ) {
                $sql =
"INSERT INTO rss_diags_$annee (code_sq_fk, rss, iep, das) VALUES (currval('rss_" . $annee . "_code_sq_pk_seq'), $rss, $iep, '$das[$das_cur]');";
                print $sql . "\n";
                $sql =
"select currval('rss_" . $annee . "_code_sq_pk_seq') as rss_diag_das;";
                print $sql . "\n";
                $das_cur++;
            }    # while das_cur
        }    # das_nbr

        if ( $dad_nbr > 0 ) {
            $dad_cur = 0;
            while ( $dad_cur < $dad_nbr ) {
                $sql =
"INSERT INTO rss_diags_$annee (code_sq_fk, rss, iep, dad) VALUES (currval('rss_" . $annee . "_code_sq_pk_seq'), $rss, $iep, '$dad[$dad_cur]');";
                print $sql . "\n";
                $sql =
"select currval('rss_" . $annee . "_code_sq_pk_seq') as rss_diags_dad;";
                print $sql . "\n";
                $dad_cur++;
            }    # while dad_cur
        }    # dad_nbr

        # Maintenant les actes
        if ( $actes_nbr > 0 ) {
            $actes_cur = 0;
            while ( $actes_cur < $actes_nbr ) {

                # On rearrange sa date aussi
                $acte_date[$actes_cur] =~ s{(.{2})(.{2})(.{4})}{\3-\2-\1};
		# Bug Cora 2005 : cette date peut �tre nulle : met donc les ' ssi n�cessaire
		if ($acte_date[$actes_cur] == "DEFAULT") {
			$acte_date[$actes_cur]="NULL";
			} else {
			$acte_date[$actes_cur]="'" . $acte_date[$actes_cur] . "'";
			}

                $sql =
"INSERT INTO rss_actes_$annee ( code_sq_fk, rss, iep, date_acte, code_ccam, phase, activite, ext_doc, modificateur, remb_exceptionnel, assoc_nonprevue, iteration) VALUES ( currval('rss_" . $annee . "_code_sq_pk_seq'), $rss, $iep, $acte_date[$actes_cur], '$acte_code_ccam[$actes_cur]', $acte_phase[$actes_cur], $acte_activite[$actes_cur], $acte_ext_doc[$actes_cur], '$acte_modificateur[$actes_cur]', '$acte_remb_exceptionnel[$actes_cur]', $acte_assoc_nonprevue[$actes_cur], $acte_iteration[$actes_cur]);";
                print $sql . "\n";
                $sql =
                  "select currval('rss_" . $annee . "_code_sq_pk_seq') as rss_acte;";
                print $sql . "\n";

                $actes_cur++;
            }    # while actes_cur
        }    # actes_nbr

    }
    elsif ( $version_rss == 113 ) {
        if ( $schema_sql != 1 ) {
            print "drop table rss_$annee cascade;
drop table rss_diags_$annee cascade;
drop table rss_actes_$annee cascade;

create table rss_$annee (
 code_sq_pk SERIAL PRIMARY KEY,
 annee int,
 version_groupage smallint,
 cmd char(4),
 ghm char(6),
 filler char(1),
 version_rss smallint,
 code_retour smallint,
 finess char(10),
 version_rum smallint,
 rss bigint,
 iep bigint,
 rum bigint,
 ddn timestamp,
 sexe char(1),
 uf smallint,
 lit_autorisation smallint,
 reserve1 smallint,
 date_entree_uf timestamp,
 entree smallint,
 provenance smallint,
 date_sortie_uf timestamp,
 sortie smallint,
 destination smallint,
 cp_residence int,
 poids_nne_entree int,
 age_gestationnel int,
 sceances_nbr smallint,
 das_nbr smallint,
 dad_nbr smallint,
 actes_nbr smallint,
 dp char(9),
 dr char(9),
 igs2 smallint,
 reserve2 char(16)
);

create table rss_diags_$annee (
 code_sq_fk INT,
 rss bigint,
 iep bigint,
 das char(9),
 dad char(9),
 FOREIGN KEY (code_sq_fk) REFERENCES rss_$annee (code_sq_pk) ON DELETE CASCADE ON UPDATE CASCADE
);

create table rss_actes_$annee (
 code_sq_fk INT,
 rss bigint,
 iep bigint,
 date_acte timestamp,
 code_ccam char(8),
 phase smallint,
 activite smallint,
 ext_doc smallint,
 modificateur char(9),
 remb_exceptionnel char(9),
 assoc_nonprevue smallint,
 iteration smallint,
 FOREIGN KEY (code_sq_fk) REFERENCES rss_$annee (code_sq_pk) ON DELETE CASCADE ON UPDATE CASCADE
);
";
            $schema_sql = 1;
        }

        $code_retour = mysubstr( $rss_line, 12, 3 );
        $finess      = mysubstr( $rss_line, 15, 9 );
        $version_rum = mysubstr( $rss_line, 24, 3 );

        # plus grand
        $rss = mysubstr( $rss_line, 27, 20 );
        $iep = mysubstr( $rss_line, 47, 20 );

        # nouveau
        $rum  = mysubstr( $rss_line, 67, 10 );
        $ddn  = mysubstr( $rss_line, 77, 8 );
        $sexe = mysubstr( $rss_line, 85, 1 );
        $uf   = mysubstr( $rss_line, 86, 4 );

        # uf_autorisation supprime
        $lit_autorisation = mysubstr( $rss_line, 90,  2 );
        $date_entree_uf   = mysubstr( $rss_line, 92,  8 );
        $entree           = mysubstr( $rss_line, 100, 1 );
        $provenance       = mysubstr( $rss_line, 101, 1 );
        $date_sortie_uf   = mysubstr( $rss_line, 102, 8 );
        $sortie           = mysubstr( $rss_line, 110, 1 );
        $destination      = mysubstr( $rss_line, 111, 1 );
        $cp_residence     = mysubstr( $rss_line, 112, 5 );
        $poids_nne_entree = mysubstr( $rss_line, 117, 4 );

        # nouveau
        $age_gestationnel = mysubstr( $rss_line, 121, 2 );
        $sceances_nbr     = mysubstr( $rss_line, 123, 2 );
        $das_nbr          = mysubstr( $rss_line, 125, 2 );
        $dad_nbr          = mysubstr( $rss_line, 127, 2 );
        $actes_nbr        = mysubstr( $rss_line, 129, 2 );
        $dp               = mysubstr( $rss_line, 131, 8 );
        $dr               = mysubstr( $rss_line, 139, 8 );
        $igs2             = mysubstr( $rss_line, 147, 3 );
        $reserve2         = mysubstr( $rss_line, 150, 15 );

        # Maintenant on parse le rss_line selon le nbr DAS/DAD/ACTES
        $offset = 165;

        if ( $das_nbr > 0 ) {
            $das_cur = 0;
            while ( $das_cur < $das_nbr ) {
                $das[$das_cur] = mysubstr( $rss_line, $offset, 8 );
                $offset = $offset + 8;
                $das_cur++;
            }    # while das_cur
        }    # das_nbr
        if ( $dad_nbr > 0 ) {
            $dad_cur = 0;
            while ( $dad_cur < $dad_nbr ) {
                $dad[$dad_cur] = mysubstr( $rss_line, $offset, 8 );
                $offset = $offset + 8;
                $dad_cur++;
            }    # while dad_cur
        }    # dad_nbr

        if ( $actes_nbr > 0 ) {
            $actes_cur = 0;
            while ( $actes_cur < $actes_nbr ) {
                $acte_date[$actes_cur] = mysubstr( $rss_line, $offset, 8 );
                $acte_code_ccam[$actes_cur] =
                  mysubstr( $rss_line, $offset + 8, 7 );
                $acte_phase[$actes_cur] =
                  mysubstr( $rss_line, $offset + 8 + 7, 1 );
                $acte_activite[$actes_cur] =
                  mysubstr( $rss_line, $offset + 8 + 7 + 1, 1 );
                $acte_ext_doc[$actes_cur] =
                  mysubstr( $rss_line, $offset + 8 + 7 + 1 + 1, 1 );
                $acte_modificateur[$actes_cur] =
                  mysubstr( $rss_line, $offset + 8 + 7 + 1 + 1 + 1, 4 );
                $acte_remb_exceptionnel[$actes_cur] =
                  mysubstr( $rss_line, $offset + 8 + 7 + 1 + 1 + 1 + 4, 1 );
                $acte_assoc_nonprevue[$actes_cur] =
                  mysubstr( $rss_line, $offset + 8 + 7 + 1 + 1 + 1 + 4 + 1, 1 );
                $acte_iteration[$actes_cur] =
                  mysubstr( $rss_line, $offset + 8 + 7 + 1 + 1 + 1 + 4 + 1 + 1,
                    2 );

                $offset = $offset + 26;
                $actes_cur++;
            }    # while actes_cur
        }    # actes_nbr
             # on est normalement � la fin de la ligne�

# maintenant que la ligne est lue, faut l'ins�rrer dans la base
#  	$dbh = DBI->connect("dbi:Pg:dbname=chu;host=localhost;port=5432", 'postgres', 'postgres', {AutoCommit => 0}) or die ("Can't connect to the database!\n");

        # On rearrage les dates au format iso
        $date_entree_uf =~ s{(.{2})(.{2})(.{4})}{\3-\2-\1};
        $date_sortie_uf =~ s{(.{2})(.{2})(.{4})}{\3-\2-\1};
        $ddn            =~ s{(.{2})(.{2})(.{4})}{\3-\2-\1};

# prepare and execute query
# pas de placeholder car perl est weakly-typed, ce qui pose des probl�mes de reconnaissance des types de values
        $sql =
"INSERT into rss_$annee (annee, version_groupage, cmd, ghm, filler, version_rss, code_retour, finess, version_rum, rss, iep, rum, ddn, sexe, uf, lit_autorisation, reserve1, date_entree_uf, entree, provenance, date_sortie_uf, sortie, destination, cp_residence, poids_nne_entree, age_gestationnel, sceances_nbr, das_nbr, dad_nbr, actes_nbr, dp, dr, igs2, reserve2) values ($annee, $version_groupage, '$cmd', '$ghm', $filler, $version_rss, $code_retour, '$finess', $version_rum, $rss, $iep, $rum, '$ddn', '$sexe', $uf, $lit_autorisation, $reserve1, '$date_entree_uf', $entree, $provenance, '$date_sortie_uf', $sortie, $destination, $cp_residence, $poids_nne_entree, $age_gestationnel, $sceances_nbr, $das_nbr, $dad_nbr, $actes_nbr, '$dp', '$dr', $igs2, $reserve2);";
        print $sql . "\n";
        $sql =
            "select currval('rss_" . $annee
          . "_code_sq_pk_seq') as transmis;";
        print $sql . "\n";

        if ( $das_nbr > 0 ) {
            $das_cur = 0;
            while ( $das_cur < $das_nbr ) {
                $sql =
"INSERT INTO rss_diags_$annee (code_sq_fk, rss, iep, das) VALUES (currval('rss_"
                  . $annee
                  . "_code_sq_pk_seq'), $rss, $iep, '$das[$das_cur]');";
                print $sql . "\n";
                $sql =
                    "select currval('rss_" . $annee
                  . "_code_sq_pk_seq') as rss_diag_das;";
                print $sql . "\n";
                $das_cur++;
            }    # while das_cur
        }    # das_nbr

        if ( $dad_nbr > 0 ) {
            $dad_cur = 0;
            while ( $dad_cur < $dad_nbr ) {
                $sql =
"INSERT INTO rss_diags_$annee (code_sq_fk, rss, iep, dad) VALUES (currval('rss_"
                  . $annee
                  . "_code_sq_pk_seq'), $rss, $iep, '$dad[$dad_cur]');";
                print $sql . "\n";
                $sql =
                    "select currval('rss_" . $annee
                  . "_code_sq_pk_seq') as rss_diags_dad;";
                print $sql . "\n";
                $dad_cur++;
            }    # while dad_cur
        }    # dad_nbr

        # Maintenant les actes
        if ( $actes_nbr > 0 ) {
            $actes_cur = 0;
            while ( $actes_cur < $actes_nbr ) {

                # On rearrange sa date aussi
                $acte_date[$actes_cur] =~ s{(.{2})(.{2})(.{4})}{\3-\2-\1};
                $sql =
"INSERT INTO rss_actes_$annee ( code_sq_fk, rss, iep, date_acte, code_ccam, phase, activite, ext_doc, modificateur, remb_exceptionnel, assoc_nonprevue, iteration) VALUES ( currval('rss_"
                  . $annee
                  . "_code_sq_pk_seq'), $rss, $iep, '$acte_date[$actes_cur]', '$acte_code_ccam[$actes_cur]', $acte_phase[$actes_cur], $acte_activite[$actes_cur], $acte_ext_doc[$actes_cur], '$acte_modificateur[$actes_cur]', '$acte_remb_exceptionnel[$actes_cur]', $acte_assoc_nonprevue[$actes_cur], $acte_iteration[$actes_cur]);";
                print $sql . "\n";
                $sql =
                    "select currval('rss_" . $annee
                  . "_code_sq_pk_seq') as rss_acte;";
                print $sql . "\n";

                $actes_cur++;
            }    # while actes_cur
        }    # actes_nbr

    }
    else {
        print "Version de RSS " . $version_rss . " non g�r�e !";
        exit(-1);
    }

    # count lines
    $line_cur++;
}    # while line_rss=IFD

print $line_cur . " lignes lues\n";
close(IFD);
