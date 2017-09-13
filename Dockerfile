ARG MW_VERSION=999
FROM kristophjunge/mediawiki:${MW_VERSION}

RUN apt-get install -y wget

# Convert the built-in uid/gid (999) to something that matches the external
# user running the container
ARG MW_USERID
ARG MW_GROUPID

RUN find / -xdev -user www-data -print0 | xargs -0 chown ${MW_USERID}
RUN find / -xdev -group www-data -print0 | xargs -0 chgrp ${MW_GROUPID}
RUN usermod -u ${MW_USERID} www-data
RUN groupmod -g ${MW_GROUPID} www-data

ARG UNUSED_USERID
ARG UNUSED_GROUPID

RUN find / -xdev -user parsoid -print0 | xargs -0 chown ${UNUSED_USERID}
RUN find / -xdev -group parsoid -print0 | xargs -0 chgrp ${UNUSED_GROUPID}
RUN usermod -u ${UNUSED_USERID} parsoid
RUN groupmod -g ${UNUSED_GROUPID} parsoid

# Prep directorios for cross mounting
RUN rm -rf /var/www/mediawiki/images /var/www/mediawiki/files
RUN mkdir -p /var/www/mediawiki/images /var/www/mediawiki/files

# Install Extensions
WORKDIR /var/www/mediawiki/
RUN cd extensions ; git clone https://github.com/mathiasertl/CustomNavBlocks.git
RUN cd extensions ; wget https://extdist.wmflabs.org/dist/extensions/WikiArticleFeeds-REL1_29-8b12cb8.tar.gz ; tar -xf WikiArticleFeeds-REL1_29-8b12cb8.tar.gz
RUN cd extensions ; wget https://extdist.wmflabs.org/dist/extensions/MobileFrontend-REL1_29-00fab28.tar.gz ; tar -xf MobileFrontend-REL1_29-00fab28.tar.gz
RUN cd extensions ; wget https://extdist.wmflabs.org/dist/extensions/Variables-REL1_29-7a95992.tar.gz ; tar -xf Variables-REL1_29-7a95992.tar.gz
RUN cd extensions ; wget https://extdist.wmflabs.org/dist/extensions/Scribunto-REL1_29-f1a4d6c.tar.gz ; tar -xf Scribunto-REL1_29-f1a4d6c.tar.gz
RUN cd extensions/Scribunto ; find . -type f -name lua | xargs chmod 755
RUN cd extensions ; wget https://github.com/jmnote/SimpleMathJax/archive/v0.6.1.tar.gz -O SimpleMathJax-v0.6.1.tar.gz ; tar -xf SimpleMathJax-v0.6.1.tar.gz ; ln -s SimpleMathJax-0.6.1 SimpleMathJax
RUN cd extensions ; wget https://extdist.wmflabs.org/dist/extensions/UploadLocal-REL1_29-1278d90.tar.gz ; tar -xf UploadLocal-REL1_29-1278d90.tar.gz
RUN cd extensions ; wget https://extdist.wmflabs.org/dist/extensions/RSS-REL1_29-ec39acf.tar.gz ; tar -xf RSS-REL1_29-ec39acf.tar.gz
RUN cd extensions ; wget https://extdist.wmflabs.org/dist/extensions/SocialProfile-REL1_29-a68a73a.tar.gz ; tar -xf SocialProfile-REL1_29-a68a73a.tar.gz
RUN cd extensions ; wget https://extdist.wmflabs.org/dist/extensions/Flow-REL1_29-5971110.tar.gz ; tar -xf Flow-REL1_29-5971110.tar.gz
RUN cd extensions ; wget https://extdist.wmflabs.org/dist/extensions/Echo-REL1_29-a3fd1af.tar.gz ; tar -xf Echo-REL1_29-a3fd1af.tar.gz
RUN cd extensions ; wget https://github.com/Alexia/DynamicPageList/archive/3.1.1.tar.gz -O DynamicPageList-3.1.1.tar.gz ; tar -xf DynamicPageList-3.1.1.tar.gz  ; ln -s DynamicPageList-3.1.1 DynamicPageList
RUN cd extensions ; wget https://extdist.wmflabs.org/dist/extensions/Thanks-REL1_29-2e4d32e.tar.gz ; tar -xf Thanks-REL1_29-2e4d32e.tar.gz
RUN cd extensions ; wget https://extdist.wmflabs.org/dist/extensions/ReplaceText-REL1_29-b02d10f.tar.gz ; tar -xf ReplaceText-REL1_29-b02d10f.tar.gz
RUN cd extensions ; wget https://extdist.wmflabs.org/dist/extensions/Widgets-REL1_29-922fe0a.tar.gz ; tar -xf Widgets-REL1_29-922fe0a.tar.gz
RUN cd extensions ; wget https://extdist.wmflabs.org/dist/extensions/ConfirmAccount-REL1_29-1e04d8c.tar.gz ; tar -xf ConfirmAccount-REL1_29-1e04d8c.tar.gz
RUN cd extensions ; wget https://extdist.wmflabs.org/dist/extensions/TweetANew-REL1_29-6cd02b9.tar.gz ; tar -xf TweetANew-REL1_29-6cd02b9.tar.gz
RUN cd extensions ; wget https://extdist.wmflabs.org/dist/extensions/PdfExport-REL1_29-1f97d77.tar.gz ; tar -xf PdfExport-REL1_29-1f97d77.tar.gz
RUN cd extensions ; wget https://extdist.wmflabs.org/dist/extensions/Babel-REL1_29-faf4229.tar.gz ; tar -xf Babel-REL1_29-faf4229.tar.gz
RUN cd extensions ; wget https://extdist.wmflabs.org/dist/extensions/cldr-REL1_29-45d6963.tar.gz ; tar -xf cldr-REL1_29-45d6963.tar.gz
RUN cd extensions ; wget https://extdist.wmflabs.org/dist/extensions/Translate-REL1_29-396125a.tar.gz ; tar -xf Translate-REL1_29-396125a.tar.gz
RUN cd extensions ; wget https://extdist.wmflabs.org/dist/extensions/UniversalLanguageSelector-REL1_29-9a49722.tar.gz ; tar -xf UniversalLanguageSelector-REL1_29-9a49722.tar.gz
RUN cd extensions ; wget https://extdist.wmflabs.org/dist/extensions/Quiz-REL1_29-38d21e3.tar.gz ; tar -xf Quiz-REL1_29-38d21e3.tar.gz
RUN cd extensions ; wget https://github.com/HydraWiki/mediawiki-embedvideo/archive/v2.7.0.zip -O EmbedVideo-v2.7.0.zip ; unzip EmbedVideo-v2.7.0.zip ; ln -s EmbedVideo-v2.7.0.zip EmbedVideo
RUN cd skins ; wget https://github.com/wikimedia/mediawiki-skins-Metrolook/archive/f2ec55b5929784d3aa9262c551db66777d33c32a.tar.gz -O Metrolook-f2ec55b5929784d3aa9262c551db66777d33c32a.tgz ; tar -xvf Metrolook-f2ec55b5929784d3aa9262c551db66777d33c32a.tgz ; ln -s mediawiki-skins-Metrolook-f2ec55b5929784d3aa9262c551db66777d33c32a Metrolook
