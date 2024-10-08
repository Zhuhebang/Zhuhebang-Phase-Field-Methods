const themeOptions = require('gatsby-theme-mupro-doc/theme-options');

const navConfig = {
    'MUPRO Basic':{
        url: 'https://mupro-doc.surge.sh',
        description: 'Learn about the MUPRO packages in general.',
        omitLandingPage: true
    },
    'MUPRO Ferroelectrics': {
        url: 'https://mupro-ferroelectric.surge.sh',
        description: 'Learn how to use the ferroelectric module.'
    },
    'MUPRO Dielectric Breakdown': {
        url: 'https://mupro-dielectricbreakdown.surge.sh',
        description: 'Learn how to use the dielectric breakdown module.'
    }
  };
  
  const footerNavConfig = {
    MUPRO: {
        href: 'https://mupro.co/',
        target: '_blank',
        rel: 'noopener noreferrer'
    },
    Contribute: {
    href: 'https://nibiru.llc'
    }
  };
  
  themes = {
    siteName: 'MUPRO Docs',
    pageTitle: 'Ferroelectric',
    menuTitle: 'MUPRO Module Platform',
    gaTrackingId: '',
    algoliaApiKey: 'e9a5d57305100ea65a89364133fccb3a',
    algoliaIndexName: 'muprodoc',
    baseUrl: 'https://mupro-ferroelectric.surge.sh/',
    twitterHandle: '',
    spectrumHandle: '',
    youtubeUrl: '',
    logoLink: 'https://mupro-ferroelectric.surge.sh/',
    baseDir: '',
    navConfig,
    footerNavConfig   
  };

module.exports = {
    pathPrefix:'/',
    plugins:[
        {
            resolve:'gatsby-theme-mupro-doc',
            options:{
                ...themeOptions,
                ...themes,
                root: __dirname,
                subtitle: 'MUPRO Ferroelectric',
                description: 'Learn about the MUPRO packages in general.',
                sidebarCategories:{
                    null:['index','installation/introduction'],
                    Documentation: [
                        'documentations/introduction',
                        'documentations/quick-tutorial',
                        'documentations/output',
                        'documentations/structure',
                        'documentations/files'
                    ],
                    // Examples: [
                    //     'examples/introduction',
                    // ],
                    // Customization:[
                    //     'customization/introduction',
                    // ],
                    // Resources: [
                    //     'resources/faq',
                    //     'resources/publications',
                    //     'resources/references',
                    // ],
                }
            }
        }
    ]
}