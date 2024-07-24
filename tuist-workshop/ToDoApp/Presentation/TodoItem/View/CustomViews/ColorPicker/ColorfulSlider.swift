//
//  ColorfulSlider.swift
//  ColorfulSlider
//
//

import UIKit
import Foundation

class ColorfulSlider: UIView {

    var value: Float {
        return slider.value
    }

    private lazy var slider = UISlider()
    private lazy var gradientLayer = CAGradientLayer()

    private let minimumValue: Float
    private let maximumValue: Float
    private let defaultValue: Float
    private let colors: [CGColor]

    init(minimumValue: Float, maximumValue: Float, defaultValue: Float, colors: [CGColor]) {
        self.minimumValue = minimumValue
        self.maximumValue = maximumValue
        self.defaultValue = defaultValue
        self.colors = colors
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = self.bounds
    }

    override func draw(_ rect: CGRect) {
        setupColorGradientLayer(cornerRadius: rect.height / 2)
        setupColorSlider()
    }

    private func setupColorSlider() {
        slider.minimumValue = minimumValue
        slider.maximumValue = maximumValue
        slider.value = defaultValue
        slider.minimumTrackTintColor = .clear
        slider.maximumTrackTintColor = .clear
        slider.addTarget(self, action: #selector(colorValueChanged), for: .valueChanged)
        slider.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(slider)

        NSLayoutConstraint.activate([
            slider.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            slider.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            slider.topAnchor.constraint(equalTo: self.topAnchor),
            slider.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }

    private func setupColorGradientLayer(cornerRadius: CGFloat) {
        gradientLayer.cornerRadius = cornerRadius
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.0)
        gradientLayer.colors = colors
        self.layer.addSublayer(gradientLayer)
    }

    func changeColors(colors: [CGColor]) {
        gradientLayer.colors = colors
    }

    @objc func colorValueChanged() {}

}
