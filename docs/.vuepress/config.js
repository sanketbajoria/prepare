module.exports = {
    title: 'Tech Prepare',
    description: 'Tip and Tricks to prepare for interview',
    themeConfig: {
        nav: [
            { text: 'Home', link: '/' },
            { text: 'Quiz', link: '/quiz/' },
            { text: 'External', link: 'https://google.com' }
        ],
        sidebar: {
            '/golang/':
                [{
                    title: "Basic",
                    collapsable: false,
                    path: '/golang/basic/',
                    sidebarDepth: 2,
                    children: [
                        'basic/00_Basics',
                        'basic/01_Data_Types',
                        'basic/02_Variable_Constants',
                        'basic/03_Flow_Condition',
                        'basic/04_array slice & variadic',
                        'basic/05_map',
                        'basic/06_struct',
                        'basic/07_defer_error',
                        'basic/08_panic_recover'
                    ]
                }]
        }
    }
}