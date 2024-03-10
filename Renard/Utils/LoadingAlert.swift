//
//  LoadingAlert.swift
//  Renard
//
//  Created by Andoni Suarez on 11/06/23.
//

import Foundation
import UIKit
import Lottie

extension UIViewController{
    func showLoading(customIcon: lottieLibrary? = nil, title: String? = nil){
        DispatchQueue.main.async { [self] in
            let viewHeight: CGFloat = 200.0 //Alto
            let cornerRadius: CGFloat = 20.0
            
            let squareView = UIView(frame: CGRect(x: 0, y: 0, width: 200.0, height: viewHeight))
            squareView.tag = 919191
            squareView.center = view.center
            squareView.backgroundColor = UIColor.white
            
            squareView.layer.shadowColor = UIColor.black.cgColor
            squareView.layer.shadowOpacity = 0.5
            squareView.layer.shadowOffset = CGSize(width: 0, height: 2)
            squareView.layer.shadowRadius = 4.0
            squareView.layer.cornerRadius = cornerRadius
            
            var animationView: LottieAnimationView?
            animationView = .init(name: customIcon?.rawValue ?? "cat")
            animationView?.frame = CGRect(x: 0, y: -50, width: viewHeight, height: viewHeight)
            
            // Agrega bordes redondeados
            animationView?.layer.cornerRadius = cornerRadius
            animationView?.contentMode = .scaleAspectFit
            animationView?.loopMode = .loop
            animationView?.animationSpeed = 0.5
            animationView?.play()
            
            squareView.addSubview(animationView ?? UIView())
            
            let label = UILabel(frame: CGRect(x: 0, y: viewHeight - 60, width: viewHeight, height: 30))
            label.textAlignment = .center
            label.text = title ?? NSLocalizedString("loading", comment: "")
            label.textColor = .black
            label.font = UIFont.boldSystemFont(ofSize: 15.0)
            
            squareView.addSubview(label)
            
            let transition = CATransition()
            transition.duration = 0.35
            transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            transition.type = CATransitionType.moveIn
            transition.subtype = CATransitionSubtype.fromTop
            squareView.layer.add(transition, forKey: nil)
            
            UIView.transition(with: self.view, duration: 0.25, options: [.curveEaseIn], animations: {
                self.view.addSubview(squareView)
            }, completion: nil)
            
            // view.addSubview(squareView)
        }
    }
    
    func hideLoading(completion: @escaping () -> Void){
        DispatchQueue.main.async { [self] in
            for subview in view.subviews {
                if subview.tag == 919191 {
                    
                    let transition = CATransition()
                    transition.duration = 0.35
                    transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
                    transition.type = CATransitionType.moveIn
                    transition.subtype = CATransitionSubtype.fromBottom
                    subview.layer.add(transition, forKey: nil)
                    
                    UIView.transition(with: self.view, duration: 0.35, options: [.curveEaseIn], animations: {
                        subview.removeFromSuperview()
                    }, completion: {_ in
                        completion()
                    })
                }
            }
        }
    }
    
    func showAlertWithLottie(lottie: lottieLibrary, labelText: String, buttonText: String? = nil ,handler: ((UIAlertAction) -> Void)? = nil) {
        if #available(macOS 10.0, *) {
            let alert = UIAlertController(title: "Renard", message: labelText, preferredStyle: .alert)
            let closeButton = UIAlertAction(title: buttonText ?? NSLocalizedString("accept", comment: ""), style: .default, handler: handler)
            alert.addAction(closeButton)
            self.present(alert, animated: true, completion: nil)
        } else {
            DispatchQueue.main.async {
                let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
                
                var animationView: LottieAnimationView!
                animationView = .init(name: lottie.rawValue)
                animationView?.frame = CGRect(x: 0, y: 0, width: 250.0, height: 150.0)
                animationView?.contentMode = .scaleAspectFit
                animationView?.animationSpeed = 0.5
                animationView?.play(fromFrame: 0, toFrame: 85, loopMode: .none)
                
                // Crear el UILabel
                let label = UILabel()
                label.text = labelText
                label.textAlignment = .center
                label.numberOfLines = 0
                
                // Añadir la imagen y el label a la alerta
                alert.view.addSubview(animationView)
                alert.view.addSubview(label)
                
                // Configurar las restricciones
                animationView.translatesAutoresizingMaskIntoConstraints = false
                label.translatesAutoresizingMaskIntoConstraints = false
                
                NSLayoutConstraint.activate([
                    animationView.topAnchor.constraint(equalTo: alert.view.topAnchor, constant: 20),
                    animationView.centerXAnchor.constraint(equalTo: alert.view.centerXAnchor),
                    animationView.heightAnchor.constraint(equalToConstant: 200),
                    
                    label.topAnchor.constraint(equalTo: animationView.bottomAnchor, constant: 20),
                    label.leadingAnchor.constraint(equalTo: alert.view.leadingAnchor, constant: 20),
                    label.trailingAnchor.constraint(equalTo: alert.view.trailingAnchor, constant: -20),
                    label.bottomAnchor.constraint(equalTo: alert.view.bottomAnchor, constant: -60)
                ])
                
                // Crear el botón de cerrar
                let closeButton = UIAlertAction(title: buttonText ?? NSLocalizedString("accept", comment: ""), style: .default, handler: handler)
                alert.addAction(closeButton)
                
                // Presentar la alerta
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}

enum lottieLibrary: String{
    case FoxLoading = "fox_load"
    case FoxSuccess = "fox_success"
    case FoxUpset = "fox_sad"
    case CatLoading = "cat"
}
