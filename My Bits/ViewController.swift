import UIKit

class ViewController: UIViewController {

    var testButton: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        createComponents()
        configureComponents()
        layoutComponents()
    }

    func createComponents() {
        self.testButton = UIButton(type: UIButtonType.RoundedRect)
        self.view.addSubview(self.testButton!);
    }
    
    func configureComponents() {
        self.testButton?.setTitle("Test Button", forState: UIControlState.Normal)
        self.testButton?.layer.borderColor = self.testButton?.titleColorForState(UIControlState.Normal)?.CGColor
        self.testButton?.layer.borderWidth = 1.0
        self.testButton?.layer.cornerRadius = 4.0
        self.view.backgroundColor = UIColor.whiteColor()
    }
    
    func layoutComponents() {
        let testButtonXConstraint = NSLayoutConstraint(
            item: self.testButton!, attribute: .CenterX,
            relatedBy: .Equal,
            toItem: self.view, attribute: .CenterX,
            multiplier: 1.0, constant: 0.0)
        let testButtonYConstraint = NSLayoutConstraint(
            item: self.testButton!, attribute: .CenterY,
            relatedBy: .Equal,
            toItem: self.view, attribute: .CenterY,
            multiplier: 1.0, constant: 0.0)
        let testButtonWConstraint = NSLayoutConstraint(
            item: self.testButton!, attribute: .Width,
            relatedBy: .Equal,
            toItem: nil, attribute: .Width,
            multiplier: 1.0, constant: 150)
        let testButtonHConstraint = NSLayoutConstraint(
            item: self.testButton!, attribute: .Height,
            relatedBy: .Equal,
            toItem: nil, attribute: .Height,
            multiplier: 1.0, constant: 50)
        testButton?.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activateConstraints([
            testButtonXConstraint,
            testButtonYConstraint,
            testButtonWConstraint,
            testButtonHConstraint
        ])
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

