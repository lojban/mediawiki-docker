<?php
/**
* HideVariousTabsFromUnauthorizedUsers
*
* @package MediaWiki
* @subpackage Extensions
*
* @author: Tim 'SVG' Weyer <t.weyer@ymail.com>
*
* @copyright Copyright (C) 2012 Tim Weyer
* @license http://www.gnu.org/copyleft/gpl.html GNU General Public License 2.0 or later
*
*/

$wgExtensionCredits['other'][] = array(
	'path'           => __FILE__,
	'name'           => 'HideVariousTabsFromUnauthorizedUsers',
	'author'         => array( 'Tim Weyer' ),
	'url'            => 'https://www.mediawiki.org/wiki/User:SVG',
	'description'    => 'Disables various view and namespace tabs from users without <tt>edit</tt> permission for Vector skin',
	'version'        => '04-12-2012',
);

// Hooks
$wgHooks['SkinTemplateNavigation'][] = 'fnHVTFUUremoveTabsFromVector';

// Tabs of view to remove
$wgHVTFUUviewsToRemove = array( 'view' /* read */, 'edit', 'addsection' /* on talkpages */, 'history' );

/**
 * @param $sktemplate Title
 * @param $links
 * @return bool
 */
function fnHVTFUUremoveTabsFromVector( SkinTemplate &$sktemplate, array &$links ) {
	global $wgUser, $wgHVTFUUviewsToRemove;

	// Only remove tabs if user isn't allowed to edit pages
	if ( $wgUser->isAllowed( 'edit' ) ) {
		return false;
	}

	// Generate XML IDs from namespace names
	$subjectId = $sktemplate->mTitle->getNamespaceKey( '' );

	// Determine if this is a talk page
	$isTalk = $sktemplate->mTitle->isTalkPage();

	// Remove talkpage tab
	if ( $subjectId == 'main' ) {
			$talkId = 'talk';
	} else {
			$talkId = "{$subjectId}_talk";
	}
	if ( !$isTalk && $links['namespaces'][$talkId] )
		unset( $links['namespaces'][$talkId] );

	// Remove actions tabs
	foreach ( $wgHVTFUUviewsToRemove as $view ) {
		if ( $links['views'][$view] )
			unset( $links['views'][$view] );
	}

	return true;
}
