RootView & ChildView & ViewController's Life-cycle
- init -
1. RootView.init()
2. ChildView.init()

- loadView -
3. ViewController#loadView()

- viewDidLoad -
4. ViewController#viewDidLoad()

- viewWillAppear -
5. ViewController#viewWillAppear()

- updateConstraints -
6. ChildView#updateConstraints()
7. ViewController#updateViewConstraints()
8. RootView#updateConstraints()

- layoutSubviews -
9. ViewController#viewWillLayoutSubviews()
10. RootView#layoutSubviews()
11. ViewController#viewDidLayoutSubviews()
12. ChildView#layoutSubviews()

- draw -
13. RootView#draw(_:)
14. ChildView#draw(_:)

- viewDidAppear -
15. ViewController#viewDidAppear()
