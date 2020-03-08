//
//  Gradient.swift
//  Sprint
//
//  Created by Mohammed Ibrahim on 2020-03-07.
//  Copyright © 2020 Mohammed Ibrahim. All rights reserved.
//

import UIKit

class Gradient {
    var gl: CAGradientLayer!

    init(colorTop: UIColor, colorBottom: UIColor) {
        self.gl = CAGradientLayer()
        self.gl.colors = [colorTop, colorBottom]
        self.gl.locations = [0.0, 1.0]
    }
}
